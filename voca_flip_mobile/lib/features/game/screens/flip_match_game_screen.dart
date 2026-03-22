import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/core/utils/error_message_utils.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';
import 'package:voca_flip_mobile/features/game/services/flip_match_game_service.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_match_game_sections.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_match_settings_sections.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_game_tile.dart';

class FlipMatchGameScreen extends StatefulWidget {
  const FlipMatchGameScreen({super.key});

  @override
  State<FlipMatchGameScreen> createState() => _FlipMatchGameScreenState();
}

class _FlipMatchGameScreenState extends State<FlipMatchGameScreen> {
  static const int _maxCardCount = 20;
  static const int _minimumDeckCards = 12;

  static const List<FlipDifficultyOption> _difficultyOptions = [
    FlipDifficultyOption(
      id: 'easy',
      title: 'Easy',
      subtitle: '12 cards. Perfect for a quick warmup.',
      gridLabel: '3x4 Grid',
      cardCount: 12,
      icon: Icons.filter_1_rounded,
    ),
    FlipDifficultyOption(
      id: 'normal',
      title: 'Normal',
      subtitle: '16 cards. Balanced challenge.',
      gridLabel: '4x4 Grid',
      cardCount: 16,
      icon: Icons.filter_2_rounded,
    ),
    FlipDifficultyOption(
      id: 'hard',
      title: 'Hard',
      subtitle: '20 cards. For memory masters only.',
      gridLabel: '4x5 Grid',
      cardCount: 20,
      icon: Icons.filter_3_rounded,
    ),
  ];

  final FlipMatchGameService _gameService = FlipMatchGameService();
  final ScrollController _deckScrollController = ScrollController();
  final Stopwatch _stopwatch = Stopwatch();

  bool _loading = true;
  String? _error;

  int _activeCardCount = 16;
  int _moves = 0;
  int _selectedDeckIndex = 0;
  bool _startingGame = false;
  bool _showingDeckEnd = false;
  FlipDifficultyOption _selectedDifficulty = _difficultyOptions[1];
  _GamePhase _phase = _GamePhase.settings;

  List<FlipGameDeck> _eligibleDecks = const [];
  List<FlipGameTileModel> _tiles = [];

  String? _firstOpenedTileId;
  bool _boardLocked = false;
  int _matchedPairs = 0;
  int _lastScore = 0;
  bool _finished = false;
  List<FlipScoreHistoryEntry> _scoreHistory = const [];
  FlipGameSummary _scoreSummary = FlipGameSummary.empty;

  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _deckScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final decks = await _gameService.fetchEligibleDecks(
        minCards: _minimumDeckCards,
      );
      final history = await _gameService.loadScoreHistory();
      final summary = await _gameService.loadScoreSummary();

      if (decks.isEmpty) {
        throw Exception(
          'No eligible decks found (minimum 12 cards required to start).',
        );
      }

      final safeSelectedIndex = _selectedDeckIndex
          .clamp(0, decks.length - 1)
          .toInt();
      final nextSelectedDeck = decks[safeSelectedIndex];
      final nextDifficulty =
          _isDifficultySupportedForDeck(_selectedDifficulty, nextSelectedDeck)
          ? _selectedDifficulty
          : _bestDifficultyForDeck(nextSelectedDeck);

      if (!mounted) return;
      setState(() {
        _eligibleDecks = decks;
        _selectedDeckIndex = safeSelectedIndex;
        _selectedDifficulty = nextDifficulty;
        _scoreHistory = history;
        _scoreSummary = summary;
        _tiles = [];
        _moves = 0;
        _matchedPairs = 0;
        _lastScore = 0;
        _finished = false;
        _elapsedSeconds = 0;
        _phase = _GamePhase.settings;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorMessageUtils.normalize(
          e,
          fallback: AppMessages.genericActionFailed,
        );
        _loading = false;
      });
    }
  }

  Future<void> _startNewGame() async {
    final selectedDeck = _selectedDeck;
    if (selectedDeck == null || _startingGame) return;

    setState(() => _startingGame = true);

    List<FlipWordPair> allPairs;
    try {
      allPairs = await _gameService.fetchWordPairsForDeck(
        deckId: selectedDeck.id,
        fixedCardCount: _maxCardCount,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _startingGame = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorMessageUtils.normalize(
              e,
              fallback: AppMessages.genericActionFailed,
            ),
          ),
        ),
      );
      return;
    }

    final random = math.Random();
    final requestedPairCount = _selectedDifficulty.cardCount ~/ 2;
    final pairCount = math.min(requestedPairCount, allPairs.length);
    if (pairCount < requestedPairCount) {
      if (!mounted) return;
      setState(() => _startingGame = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deck "${selectedDeck.title}" does not have enough cards for ${_selectedDifficulty.title} mode.',
          ),
        ),
      );
      return;
    }

    final selectedPairs = [...allPairs]..shuffle(random);
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
      _activeCardCount = pairCount * 2;
      _tiles = tiles;
      _firstOpenedTileId = null;
      _boardLocked = false;
      _matchedPairs = 0;
      _moves = 0;
      _finished = false;
      _lastScore = 0;
      _elapsedSeconds = 0;
      _phase = _GamePhase.game;
      _startingGame = false;
    });
  }

  FlipGameDeck? get _selectedDeck {
    if (_eligibleDecks.isEmpty) return null;
    if (_selectedDeckIndex < 0 || _selectedDeckIndex >= _eligibleDecks.length) {
      return _eligibleDecks.first;
    }
    return _eligibleDecks[_selectedDeckIndex];
  }

  bool _isDifficultySupportedForDeck(
    FlipDifficultyOption option,
    FlipGameDeck? deck,
  ) {
    if (deck == null) return false;
    return deck.totalCards >= option.cardCount;
  }

  FlipDifficultyOption _bestDifficultyForDeck(FlipGameDeck? deck) {
    for (final option in _difficultyOptions.reversed) {
      if (_isDifficultySupportedForDeck(option, deck)) {
        return option;
      }
    }
    return _difficultyOptions.first;
  }

  void _onSelectDifficulty(FlipDifficultyOption option) {
    final deck = _selectedDeck;
    if (_isDifficultySupportedForDeck(option, deck)) {
      setState(() => _selectedDifficulty = option);
      return;
    }

    final suitable = _bestDifficultyForDeck(deck);
    final totalCards = deck?.totalCards ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'This deck has $totalCards cards, which is not enough for ${option.title}. Please use ${suitable.title} mode.',
        ),
      ),
    );

    setState(() => _selectedDifficulty = suitable);
  }

  String _buildDifficultySupportHint(FlipGameDeck? deck) {
    if (deck == null) return 'Choose a deck to begin.';
    if (deck.totalCards >= 20) {
      return 'This deck supports Easy, Normal, and Hard.';
    }
    if (deck.totalCards >= 16) {
      return 'This deck supports Easy and Normal. Hard requires at least 20 cards.';
    }
    return 'This deck supports only Easy mode (minimum 12 cards).';
  }

  Future<void> _toggleViewAllDecks() async {
    if (!_deckScrollController.hasClients) return;

    final targetOffset = _showingDeckEnd
        ? 0.0
        : _deckScrollController.position.maxScrollExtent;

    await _deckScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;
    setState(() => _showingDeckEnd = !_showingDeckEnd);
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
      setState(() => _firstOpenedTileId = tile.id);
      return;
    }

    final firstId = _firstOpenedTileId!;
    if (firstId == tile.id) return;

    final firstIndex = _tiles.indexWhere((t) => t.id == firstId);
    if (firstIndex == -1) {
      setState(() => _firstOpenedTileId = null);
      return;
    }

    final firstTile = _tiles[firstIndex];
    final isMatch =
        firstTile.pairId == tile.pairId && firstTile.side != tile.side;

    setState(() {
      _boardLocked = true;
      _moves += 1;
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
    final pairs = _activeCardCount ~/ 2;
    final perfectMoves = math.max(1, pairs);
    final accuracy = (perfectMoves / math.max(_moves, perfectMoves)).clamp(
      0.0,
      1.0,
    );
    final score = ((_activeCardCount * 1000) * accuracy / ((seconds / 10) + 1))
        .round();

    setState(() {
      _finished = true;
      _lastScore = score;
      _elapsedSeconds = seconds;
    });

    final selectedDeck = _selectedDeck;
    final entry = FlipScoreHistoryEntry(
      score: score,
      seconds: seconds,
      cardCount: _activeCardCount,
      moves: _moves,
      playedAt: DateTime.now(),
    );

    final previousHistory = _scoreHistory;

    // Update local history immediately so score is visible right after finishing.
    final optimisticHistory = [
      entry,
      ...previousHistory,
    ].take(FlipMatchGameService.maxHistoryItems).toList();
    setState(() {
      _scoreHistory = optimisticHistory;
    });

    final updatedSummary = await _gameService.saveScoreHistoryEntry(
      entry: entry,
      deckId: selectedDeck?.id,
      existing: previousHistory,
    );
    final updatedHistory = await _gameService.loadScoreHistory();

    if (!mounted) return;
    setState(() {
      _scoreHistory = updatedHistory;
      _scoreSummary = updatedSummary;
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _resolveColumns() {
    // Keep board shape consistent with selected mode:
    // Easy 3x4, Normal 4x4, Hard 4x5.
    if (_activeCardCount <= 12) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loadInitialData,
                  child: const Text(AppMessages.tryAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF6F6FF),
      appBar: _buildTopBar(),
      bottomNavigationBar: _phase == _GamePhase.settings
          ? FlipMatchStartButtonBar(
              startingGame: _startingGame,
              hasDecks: _eligibleDecks.isNotEmpty,
              onStart: _startNewGame,
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFF0F3FF)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadInitialData,
            color: AppColors.primary,
            child: _phase == _GamePhase.settings
                ? _buildSettingsView()
                : _buildGameView(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.84),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: _phase == _GamePhase.game
          ? IconButton(
              onPressed: () {
                _ticker?.cancel();
                _stopwatch.stop();
                setState(() => _phase = _GamePhase.settings);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.primary,
            )
          : null,
      title: Text(
        _phase == _GamePhase.settings ? 'Memory Challenge' : 'Memory Match',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1F3EAB),
        ),
      ),
      actions: const [],
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 92, 16, 140),
      children: [
        Text(
          'Prepare your mind.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 34,
            height: 1.08,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2238),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your deck and difficulty to begin the training session.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: const Color(0xFF5A637D),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        FlipDeckSelectorSection(
          decks: _eligibleDecks,
          selectedDeckIndex: _selectedDeckIndex,
          showingDeckEnd: _showingDeckEnd,
          scrollController: _deckScrollController,
          onToggleViewAllDecks: _toggleViewAllDecks,
          onSelectDeck: (index) {
            setState(() {
              _selectedDeckIndex = index;
              final selectedDeck = _eligibleDecks[index];
              if (!_isDifficultySupportedForDeck(
                _selectedDifficulty,
                selectedDeck,
              )) {
                _selectedDifficulty = _bestDifficultyForDeck(selectedDeck);
              }
            });
          },
        ),
        const SizedBox(height: 20),
        FlipDifficultySection(
          hint: _buildDifficultySupportHint(_selectedDeck),
          options: _difficultyOptions,
          selectedOptionId: _selectedDifficulty.id,
          isOptionSupported: (option) =>
              _isDifficultySupportedForDeck(option, _selectedDeck),
          onSelectOption: _onSelectDifficulty,
        ),
        const SizedBox(height: 14),
        FlipPastPerformanceCard(
          history: _scoreHistory,
          summary: _scoreSummary,
          formatDuration: _formatDuration,
        ),
      ],
    );
  }

  Widget _buildGameView() {
    final columnCount = _resolveColumns();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 92, 16, 24),
      children: [
        FlipMatchGameStatusCard(
          elapsedSeconds: _elapsedSeconds,
          moves: _moves,
          score: _lastScore,
          formatDuration: _formatDuration,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final tile = _tiles[index];
            return FlipGameTile(tile: tile, onTap: () => _onTileTap(tile.id));
          },
        ),
        const SizedBox(height: 16),
        if (_finished)
          FlipMatchFinishedCard(
            activeCardCount: _activeCardCount,
            moves: _moves,
            elapsedSeconds: _elapsedSeconds,
            lastScore: _lastScore,
            formatDuration: _formatDuration,
            onPlayAgain: _startNewGame,
            onBackToDecks: () => setState(() => _phase = _GamePhase.settings),
          ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E8F6)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: Color(0xFF7E2DA6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pro tip: Match the English word with its Vietnamese meaning to keep your streak alive.',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF58617E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

enum _GamePhase { settings, game }
