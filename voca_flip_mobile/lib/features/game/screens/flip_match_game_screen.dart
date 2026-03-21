import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';
import 'package:voca_flip_mobile/features/game/services/flip_match_game_service.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_game_done_state.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_game_tile.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_game_top_panel.dart';

class FlipMatchGameScreen extends StatefulWidget {
  const FlipMatchGameScreen({super.key});

  @override
  State<FlipMatchGameScreen> createState() => _FlipMatchGameScreenState();
}

class _FlipMatchGameScreenState extends State<FlipMatchGameScreen> {
  static const _fixedCardCount = 16;
  static const _minRequiredPairs = _fixedCardCount ~/ 2;

  final FlipMatchGameService _gameService = FlipMatchGameService();
  final Stopwatch _stopwatch = Stopwatch();

  bool _loading = true;
  String? _error;

  int _activeCardCount = _fixedCardCount;

  List<FlipWordPair> _allPairs = const [];
  List<FlipGameTileModel> _tiles = [];

  String? _firstOpenedTileId;
  bool _boardLocked = false;
  int _matchedPairs = 0;
  int _lastScore = 0;
  bool _finished = false;
  bool _gameStarted = false;
  List<FlipScoreHistoryEntry> _scoreHistory = const [];

  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadScoreHistory();
    _loadPairsAndStartGame();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadPairsAndStartGame() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pairs = await _gameService.fetchWordPairsForGame(
        fixedCardCount: _fixedCardCount,
      );

      if (pairs.length < _minRequiredPairs) {
        throw Exception('Can it nhat 8 cap tu-viet nghia de choi (16 the).');
      }

      setState(() {
        _allPairs = pairs;
        _tiles = [];
        _matchedPairs = 0;
        _lastScore = 0;
        _finished = false;
        _elapsedSeconds = 0;
        _gameStarted = false;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _loadScoreHistory() async {
    final parsed = await _gameService.loadScoreHistory();
    if (!mounted) return;

    setState(() {
      _scoreHistory = parsed;
    });
  }

  Future<void> _saveScoreHistoryEntry(FlipScoreHistoryEntry entry) async {
    final updated = await _gameService.saveScoreHistoryEntry(
      entry: entry,
      existing: _scoreHistory,
    );

    if (!mounted) return;
    setState(() {
      _scoreHistory = updated;
    });
  }

  void _startNewGame() {
    if (_allPairs.isEmpty) return;

    final random = math.Random();
    final pairCount = _fixedCardCount ~/ 2;
    final selectedPairs = [..._allPairs]..shuffle(random);
    final gamePairs = selectedPairs.take(pairCount).toList();

    final tiles = <FlipGameTileModel>[];
    for (var i = 0; i < gamePairs.length; i++) {
      final pair = gamePairs[i];
      final pairId = 'pair_$i';
      tiles.add(
        FlipGameTileModel(
          id: '${pairId}_w',
          pairId: pairId,
          text: pair.word,
          side: FlipTileSide.word,
        ),
      );
      tiles.add(
        FlipGameTileModel(
          id: '${pairId}_m',
          pairId: pairId,
          text: pair.meaning,
          side: FlipTileSide.meaning,
        ),
      );
    }

    tiles.shuffle(random);

    _ticker?.cancel();
    _stopwatch
      ..reset()
      ..start();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds = _stopwatch.elapsed.inSeconds;
      });
    });

    setState(() {
      _activeCardCount = _fixedCardCount;
      _tiles = tiles;
      _firstOpenedTileId = null;
      _boardLocked = false;
      _matchedPairs = 0;
      _finished = false;
      _lastScore = 0;
      _elapsedSeconds = 0;
      _gameStarted = true;
    });
  }

  void _handlePrimaryAction() {
    _startNewGame();
  }

  int _resolveColumns(int itemCount) {
    if (itemCount >= 18) return 6;
    return 4;
  }

  Future<void> _onTileTap(String tileId) async {
    if (_boardLocked || _finished) return;

    final tileIndex = _tiles.indexWhere((t) => t.id == tileId);
    if (tileIndex == -1) return;

    final tile = _tiles[tileIndex];
    if (tile.isMatched || tile.isFaceUp) return;

    setState(() {
      tile.isFaceUp = true;
    });

    if (_firstOpenedTileId == null) {
      setState(() {
        _firstOpenedTileId = tile.id;
      });
      return;
    }

    final firstId = _firstOpenedTileId!;
    if (firstId == tile.id) return;

    final firstIndex = _tiles.indexWhere((t) => t.id == firstId);
    if (firstIndex == -1) {
      setState(() {
        _firstOpenedTileId = null;
      });
      return;
    }

    final firstTile = _tiles[firstIndex];
    final isMatch =
        firstTile.pairId == tile.pairId && firstTile.side != tile.side;

    setState(() {
      _boardLocked = true;
    });

    if (isMatch) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      setState(() {
        firstTile.isMatched = true;
        tile.isMatched = true;
        _matchedPairs += 1;
        _firstOpenedTileId = null;
        _boardLocked = false;
      });

      if (_matchedPairs == _activeCardCount ~/ 2) {
        await _finishGame();
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      firstTile.isFaceUp = false;
      tile.isFaceUp = false;
      _firstOpenedTileId = null;
      _boardLocked = false;
    });
  }

  Future<void> _finishGame() async {
    _stopwatch.stop();
    _ticker?.cancel();

    final seconds = math.max(1, _stopwatch.elapsed.inSeconds);
    final score = ((_activeCardCount * 1200) / (seconds + 10)).round();

    setState(() {
      _finished = true;
      _lastScore = score;
      _elapsedSeconds = seconds;
    });

    await _saveScoreHistoryEntry(
      FlipScoreHistoryEntry(
        score: score,
        seconds: seconds,
        cardCount: _activeCardCount,
        playedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hoan thanh!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thoi gian: ${_formatDuration(seconds)}'),
              const SizedBox(height: 6),
              Text('Diem: $_lastScore'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dong'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
              child: const Text('Choi lai'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final m = mins.toString().padLeft(2, '0');
    final s = secs.toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadPairsAndStartGame,
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      );
    }

    final columnCount = _resolveColumns(_activeCardCount);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        title: Text('Flip Match Game', style: AppTextStyles.authHeroTitle),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadPairsAndStartGame,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              FlipGameTopPanel(
                elapsedText: _formatDuration(_elapsedSeconds),
                matchedText: '$_matchedPairs/${_activeCardCount ~/ 2}',
                cardsText: '$_activeCardCount',
                isFinished: _finished,
                scoreText: '$_lastScore',
                scoreHistory: _scoreHistory,
                primaryButtonLabel: _gameStarted ? 'New Game' : 'Bat dau',
                primaryButtonIcon: _gameStarted
                    ? Icons.shuffle
                    : Icons.play_arrow_rounded,
                onPrimaryAction: _handlePrimaryAction,
                formatDuration: _formatDuration,
                formatDateTime: _formatDateTime,
              ),
              const SizedBox(height: 14),
              if (_gameStarted)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: columnCount >= 6 ? 0.95 : 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final tile = _tiles[index];
                    return FlipGameTile(
                      tile: tile,
                      onTap: () => _onTileTap(tile.id),
                    );
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Text(
                    'Nhan "Bat dau" de vao van choi Flip Match.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              if (_finished) ...[
                const SizedBox(height: 14),
                FlipGameDoneState(
                  elapsedText: _formatDuration(_elapsedSeconds),
                  scoreText: '$_lastScore',
                  onPlayAgain: _startNewGame,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
