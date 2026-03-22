import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/core/utils/error_message_utils.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';
import 'package:voca_flip_mobile/features/game/services/flip_match_game_service.dart';
import 'package:voca_flip_mobile/features/game/widgets/flip_game_tile.dart';

class FlipMatchGameScreen extends StatefulWidget {
  const FlipMatchGameScreen({super.key});

  @override
  State<FlipMatchGameScreen> createState() => _FlipMatchGameScreenState();
}

class _FlipMatchGameScreenState extends State<FlipMatchGameScreen> {
  static const int _maxCardCount = 20;
  static const int _minimumDeckCards = 12;

  static const List<_DifficultyOption> _difficultyOptions = [
    _DifficultyOption(
      id: 'easy',
      title: 'Easy',
      subtitle: '12 cards. Perfect for a quick warmup.',
      gridLabel: '3x4 Grid',
      cardCount: 12,
      icon: Icons.filter_1_rounded,
    ),
    _DifficultyOption(
      id: 'normal',
      title: 'Normal',
      subtitle: '16 cards. Balanced challenge.',
      gridLabel: '4x4 Grid',
      cardCount: 16,
      icon: Icons.filter_2_rounded,
    ),
    _DifficultyOption(
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
  _DifficultyOption _selectedDifficulty = _difficultyOptions[1];
  _GamePhase _phase = _GamePhase.settings;

  List<FlipGameDeck> _eligibleDecks = const [];
  List<FlipGameTileModel> _tiles = [];

  String? _firstOpenedTileId;
  bool _boardLocked = false;
  int _matchedPairs = 0;
  int _lastScore = 0;
  bool _finished = false;
  List<FlipScoreHistoryEntry> _scoreHistory = const [];

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

      if (decks.isEmpty) {
        throw Exception(
          'No eligible decks found (minimum 12 cards required to start).',
        );
  

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
    _DifficultyOption option,
    FlipGameDeck? deck,
  ) {
    if (deck == null) return false;
    return deck.totalCards >= option.cardCount;
  }

  _DifficultyOption _bestDifficultyForDeck(FlipGameDeck? deck) {
    for (final option in _difficultyOptions.reversed) {
      if (_isDifficultySupportedForDeck(option, deck)) {
        return option;
      }
    }
    return _difficultyOptions.first;
  }

  void _onSelectDifficulty(_DifficultyOption option) {
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

    await _gameService.saveScoreHistoryEntry(
      entry: entry,
      deckId: selectedDeck?.id,
      existing: previousHistory,
    );
    final updatedHistory = await _gameService.loadScoreHistory();

    if (!mounted) return;
    setState(() {
      _scoreHistory = updatedHistory;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time: ${_formatDuration(seconds)}'),
              const SizedBox(height: 6),
              Text('Score: $_lastScore'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
              child: const Text('Play again'),
            ),
          ],
        );
      },
    );
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
          ? _buildStartButtonBar()
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
        Row(
          children: [
            Text(
              'Select Deck',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27324D),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: _toggleViewAllDecks,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  _showingDeckEnd ? 'Back' : 'View All',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 206,
          child: ListView.separated(
            controller: _deckScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _eligibleDecks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final deck = _eligibleDecks[index];
              final isSelected = _selectedDeckIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDeckIndex = index;
                    final selectedDeck = _eligibleDecks[index];
                    if (!_isDifficultySupportedForDeck(
                      _selectedDifficulty,
                      selectedDeck,
                    )) {
                      _selectedDifficulty = _bestDifficultyForDeck(
                        selectedDeck,
                      );
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFD6E0FF),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 110,
                          width: double.infinity,
                          child: deck.coverImageUrl != null
                              ? Image.network(
                                  deck.coverImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFE6ECFF),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFE6ECFF),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.layers_rounded,
                                    color: AppColors.textHint,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        deck.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2A45),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${deck.totalCards} Cards',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7D869F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Difficulty Level',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF27324D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _buildDifficultySupportHint(_selectedDeck),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF66718E),
          ),
        ),
        const SizedBox(height: 10),
        ..._difficultyOptions.map(_buildDifficultyTile),
        const SizedBox(height: 14),
        _buildPastPerformanceCard(),
      ],
    );
  }

  Widget _buildDifficultyTile(_DifficultyOption option) {
    final supported = _isDifficultySupportedForDeck(option, _selectedDeck);
    final selected = option.id == _selectedDifficulty.id && supported;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _onSelectDifficulty(option),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: supported ? Colors.white : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (supported
                        ? const Color(0xFFD8E0F5)
                        : const Color(0xFFE2E5EF)),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: !supported
                    ? Colors.transparent
                    : selected
                    ? AppColors.primary.withValues(alpha: 0.13)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: selected ? 20 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Opacity(
            opacity: supported ? 1 : 0.62,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFE8EEFF),
                  ),
                  child: Icon(
                    option.icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            option.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B233A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFDCE7FF)
                                  : const Color(0xFFF0F3FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              supported
                                  ? option.gridLabel
                                  : 'Need ${option.cardCount} Cards',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? const Color(0xFF1136A8)
                                    : const Color(0xFF66718E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        option.subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF66718E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFB6BED6),
                      width: 1.6,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.circle, size: 8, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastPerformanceCard() {
    final bestSeconds = _scoreHistory.isEmpty
        ? null
        : _scoreHistory
              .map((entry) => entry.seconds)
              .reduce((a, b) => a < b ? a : b);

    final bestAccuracy = _scoreHistory
        .map((entry) {
          final pairs = math.max(1, entry.cardCount ~/ 2);
          final moves = math.max(pairs, entry.moves);
          return (pairs / moves) * 100;
        })
        .fold<double>(0, math.max);

    final topScores = [..._scoreHistory]
      ..sort((a, b) => b.score.compareTo(a.score));
    final top3 = topScores.take(3).toList();

    String scoreAt(int index) {
      if (index >= top3.length) return '--';
      return top3[index].score.toString();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Past Performance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2440),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  'BEST TIME',
                  bestSeconds == null ? '--:--' : _formatDuration(bestSeconds),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  'ACCURACY',
                  bestAccuracy == 0
                      ? '-- %'
                      : '${bestAccuracy.round().clamp(0, 100)} %',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statBox('TOP 1', scoreAt(0))),
              const SizedBox(width: 10),
              Expanded(child: _statBox('TOP 2', scoreAt(1))),
              const SizedBox(width: 10),
              Expanded(child: _statBox('TOP 3', scoreAt(2))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7E89A7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D2642),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    final columnCount = _resolveColumns();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 92, 16, 24),
      children: [
        _buildGameStatusCard(),
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
        if (_finished) _buildFinishedCard(),
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

  Widget _buildGameStatusCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statusItem(
              icon: Icons.timer_rounded,
              label: 'TIMER',
              value: _formatDuration(_elapsedSeconds),
              iconBg: const Color(0xFFDCE7FF),
              valueColor: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 38, color: const Color(0xFFCFD8F5)),
          Expanded(
            child: _statusItem(
              icon: Icons.ads_click_rounded,
              label: 'MOVES',
              value: _moves.toString(),
              iconBg: const Color(0xFFF0DBFF),
              valueColor: const Color(0xFF9C33C7),
            ),
          ),
          Container(width: 1, height: 38, color: const Color(0xFFCFD8F5)),
          Expanded(
            child: _statusItem(
              icon: Icons.workspace_premium_rounded,
              label: 'SCORE',
              value: _lastScore.toString(),
              iconBg: const Color(0xFFFFE8C6),
              valueColor: const Color(0xFFC97A00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7680A0),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedCard() {
    final pairCount = math.max(1, _activeCardCount ~/ 2);
    final accuracy = ((pairCount / math.max(_moves, pairCount)) * 100)
        .round()
        .clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E0FF)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Great run!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF202B47),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Time ${_formatDuration(_elapsedSeconds)} • Score $_lastScore • Accuracy $accuracy%',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF626C89),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _startNewGame,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Play Again'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _phase = _GamePhase.settings),
                  icon: const Icon(Icons.view_carousel_rounded),
                  label: const Text('Back to Decks'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButtonBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A4ED6), Color(0xFF4D84FF)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: FilledButton.icon(
              onPressed: _startingGame || _eligibleDecks.isEmpty
                  ? null
                  : _startNewGame,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              icon: _startingGame
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                _startingGame ? 'Preparing...' : 'Start Game',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _GamePhase { settings, game }

class _DifficultyOption {
  const _DifficultyOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gridLabel,
    required this.cardCount,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String gridLabel;
  final int cardCount;
  final IconData icon;
}
