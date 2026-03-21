import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/features/study/models/responses/study_session_response.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/study/study_screen.dart';
import 'package:voca_flip_mobile/features/deck/screens/deck_detail_screen.dart';
import 'package:voca_flip_mobile/features/deck/screens/deck_list_screen.dart';
import 'package:voca_flip_mobile/features/home/widgets/home_header.dart';
import 'package:voca_flip_mobile/features/home/widgets/home_stats_grid.dart';
import 'package:voca_flip_mobile/features/home/widgets/space_repetition_card.dart';
import 'package:voca_flip_mobile/features/home/widgets/deck_grid_item.dart';
import 'package:voca_flip_mobile/features/study/screens/due_for_review_list_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;
  String? _error;

  String _userName = 'User';
  String? _avatarUrl;
  int _streakDays = 0;
  int _masteredWords = 0;

  int _dueCount = 0;

  List<Map<String, dynamic>> _decks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = ApiService(prefs);

      final results = await Future.wait([
        api.get('/api/user/me'),
        api.get('/api/decks/my-decks'),
        api.get('/api/study/due-cards-count'),
        api.get('/api/learning-progress/me'),
      ]);

      final userResult = results[0].data['result'];
      final statsResult = results[3].data['result'];
      _userName = userResult['name'] ?? 'User';
      _avatarUrl = userResult['avatarUrl'];
      _streakDays = statsResult['streakDays'] ?? userResult['streakDays'] ?? 0;
      _masteredWords = userResult['masteredWords'] ?? 0;

      final deckResult = results[1].data['result'] as List<dynamic>;
      _decks = deckResult.cast<Map<String, dynamic>>();

      _dueCount = results[2].data['result'] ?? 0;

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _startDailyReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final api = ApiService(prefs);
      final res = await api.post('/api/study/daily-review');
      final sessionData = StudySessionResponse.fromJson(
        res.data['result'] as Map<String, dynamic>,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudyScreen(sessionData: sessionData),
        ),
      );

      if (mounted) {
        _loadData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(userName: _userName, avatarUrl: _avatarUrl),

            HomeStatsGrid(
              streakDays: _streakDays,
              masteredWords: _masteredWords,
            ),

            SpaceRepetitionCard(
              dueCount: _dueCount,
              onStartReview: _startDailyReview,
              onCardTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const DueForReviewListScreen(),
                      ),
                    )
                    .then((result) {
                      if (result == true && mounted) {
                        _loadData();
                      }
                    });
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'My Decks',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_decks.length}',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeckListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _decks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No decks found')),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _decks.length > 4 ? 4 : _decks.length,
                      itemBuilder: (context, index) {
                        final deck = _decks[index];
                        return DeckGridItem(
                          title: deck['title'] ?? 'Untitled',
                          coverImageUrl: deck['coverImageUrl'],
                          totalCards: deck['totalCards'] ?? 0,
                          onTap: () {
                            // Điều hướng đến trang chi tiết deck
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeckDetailScreen(deckId: deck['id']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
