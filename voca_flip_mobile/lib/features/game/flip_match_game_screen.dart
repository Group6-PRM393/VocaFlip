import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/deck/models/card_model.dart';
import 'package:voca_flip_mobile/features/deck/models/deck_model.dart';

class FlipMatchGameScreen extends StatefulWidget {
  const FlipMatchGameScreen({super.key});

  @override
  State<FlipMatchGameScreen> createState() => _FlipMatchGameScreenState();
}

class _FlipMatchGameScreenState extends State<FlipMatchGameScreen> {
  final Stopwatch _stopwatch = Stopwatch();

  bool _loading = true;
  String? _error;

  int _selectedCardCount = 12;
  int _activeCardCount = 12;

  List<_WordPair> _allPairs = const [];
  List<_GameTile> _tiles = [];

  String? _firstOpenedTileId;
  bool _boardLocked = false;
  int _matchedPairs = 0;
  int _lastScore = 0;
  bool _finished = false;

  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
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
      final prefs = await SharedPreferences.getInstance();
      final api = ApiService(prefs);

      final deckRes = await api.get('/api/decks/my-decks');
      final deckBody = deckRes.data;
      final deckRaw = (deckBody is Map<String, dynamic>)
          ? deckBody['result']
          : deckBody;

      if (deckRaw is! List) {
        throw Exception('Khong the tai danh sach deck.');
      }

      final decks = deckRaw
          .map((e) => DeckModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (decks.isEmpty) {
        throw Exception('Ban chua co deck nao de choi game.');
      }

      final random = math.Random();
      final shuffledDecks = [...decks]..shuffle(random);

      final uniquePairs = <String, _WordPair>{};

      for (final deck in shuffledDecks) {
        final cardsRes = await api.get('/api/cards/deck/${deck.id}');
        final cardsBody = cardsRes.data;

        List<CardModel> cards;
        if (cardsBody is List) {
          cards = cardsBody
              .map(
                (e) => CardModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        } else if (cardsBody is Map<String, dynamic>) {
          final list =
              cardsBody['result'] ?? cardsBody['data'] ?? cardsBody['items'];
          if (list is! List) {
            continue;
          }
          cards = list
              .map(
                (e) => CardModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        } else {
          continue;
        }

        for (final card in cards) {
          final word = card.front.trim();
          final meaning = card.back.trim();
          if (word.isEmpty || meaning.isEmpty) continue;

          final key = '${word.toLowerCase()}|${meaning.toLowerCase()}';
          uniquePairs[key] = _WordPair(
            id: card.id,
            word: word,
            meaning: meaning,
          );
        }

        if (uniquePairs.length >= 18) {
          break;
        }
      }

      final pairs = uniquePairs.values.toList();
      if (pairs.length < 6) {
        throw Exception('Can it nhat 6 cap tu-viet nghia de choi (12 the).');
      }

      final maxCards = math.min(36, pairs.length * 2);
      final defaultCards = math.min(12, maxCards);

      setState(() {
        _allPairs = pairs;
        _selectedCardCount = defaultCards;
        _loading = false;
      });

      _startNewGame();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  List<int> get _availableCardCounts {
    if (_allPairs.isEmpty) return const [];
    final maxCards = math.min(36, _allPairs.length * 2);
    final values = <int>[];
    for (var count = 12; count <= maxCards; count += 2) {
      values.add(count);
    }
    return values;
  }

  void _startNewGame() {
    if (_allPairs.isEmpty) return;

    final random = math.Random();
    final availablePairs = _allPairs.length;

    var targetCards = _selectedCardCount;
    targetCards = targetCards.clamp(12, math.min(36, availablePairs * 2));

    final pairCount = targetCards ~/ 2;
    final selectedPairs = [..._allPairs]..shuffle(random);
    final gamePairs = selectedPairs.take(pairCount).toList();

    final tiles = <_GameTile>[];
    for (var i = 0; i < gamePairs.length; i++) {
      final pair = gamePairs[i];
      final pairId = 'pair_$i';
      tiles.add(
        _GameTile(
          id: '${pairId}_w',
          pairId: pairId,
          text: pair.word,
          side: _TileSide.word,
        ),
      );
      tiles.add(
        _GameTile(
          id: '${pairId}_m',
          pairId: pairId,
          text: pair.meaning,
          side: _TileSide.meaning,
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
      _activeCardCount = targetCards;
      _tiles = tiles;
      _firstOpenedTileId = null;
      _boardLocked = false;
      _matchedPairs = 0;
      _finished = false;
      _lastScore = 0;
      _elapsedSeconds = 0;
    });
  }

  int _resolveColumns(int itemCount) {
    if (itemCount >= 30) return 6;
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
        _finishGame();
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

  void _finishGame() {
    _stopwatch.stop();
    _ticker?.cancel();

    final seconds = math.max(1, _stopwatch.elapsed.inSeconds);
    final score = ((_activeCardCount * 1200) / (seconds + 10)).round();

    setState(() {
      _finished = true;
      _lastScore = score;
      _elapsedSeconds = seconds;
    });

    showDialog<void>(
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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

    final activeTiles = _tiles.where((t) => !t.isMatched).toList();
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
              _buildTopPanel(),
              const SizedBox(height: 14),
              if (activeTiles.isEmpty)
                _buildEmptyDoneState()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeTiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: columnCount >= 6 ? 0.95 : 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final tile = activeTiles[index];
                    return _FlipGameTile(
                      tile: tile,
                      onTap: () => _onTileTap(tile.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    final counts = _availableCardCounts;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip('Time', _formatDuration(_elapsedSeconds)),
              _statChip('Matched', '$_matchedPairs/${_activeCardCount ~/ 2}'),
              _statChip('Cards', '$_activeCardCount'),
              if (_finished) _statChip('Score', '$_lastScore'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: counts.contains(_selectedCardCount)
                      ? _selectedCardCount
                      : counts.first,
                  items: counts
                      .map(
                        (count) => DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count the'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCardCount = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'So the',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _startNewGame,
                icon: const Icon(Icons.shuffle),
                label: const Text('New Game'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDoneState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text('Ban da ghep het cap the!', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            'Thoi gian ${_formatDuration(_elapsedSeconds)} • Diem $_lastScore',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _startNewGame,
            child: const Text('Choi van moi'),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipGameTile extends StatelessWidget {
  const _FlipGameTile({required this.tile, required this.onTap});

  final _GameTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: tile.isFaceUp ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        builder: (context, value, child) {
          final angle = value * math.pi;
          final showFront = angle >= math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: _faceUpContent(),
                  )
                : _faceDownContent(),
          );
        },
      ),
    );
  }

  Widget _faceDownContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _faceUpContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tile.side == _TileSide.word
              ? const Color(0xFF93C5FD)
              : const Color(0xFFFDE68A),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tile.side == _TileSide.word ? 'WORD' : 'MEANING',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tile.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordPair {
  const _WordPair({
    required this.id,
    required this.word,
    required this.meaning,
  });

  final String id;
  final String word;
  final String meaning;
}

enum _TileSide { word, meaning }

class _GameTile {
  _GameTile({
    required this.id,
    required this.pairId,
    required this.text,
    required this.side,
  });

  final String id;
  final String pairId;
  final String text;
  final _TileSide side;

  bool isFaceUp = false;
  bool isMatched = false;
}
