import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/study/models/responses/study_session_response.dart';
import 'package:voca_flip_mobile/features/study/models/responses/study_card_response.dart';
import 'package:voca_flip_mobile/features/study/study_screen.dart';

class DueForReviewListScreen extends StatefulWidget {
  const DueForReviewListScreen({super.key});

  @override
  State<DueForReviewListScreen> createState() => _DueForReviewListScreenState();
}

class _DueForReviewListScreenState extends State<DueForReviewListScreen> {
  bool _loading = true;
  String? _error;
  StudySessionResponse? _sessionData;
  List<StudyCardResponse> _comingUpCards = const [];

  // User stats
  int _streakDays = 0;

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

      // Fetch user info + due count + upcoming cards in parallel
      final results = await Future.wait([
        api.get('/api/user/me'),
        api.get('/api/study/due-cards-count'),
        api.get(
          '/api/study/upcoming-cards',
          queryParameters: {'withinHours': 3},
        ),
      ]);

      final userResult = results[0].data['result'];
      _streakDays = userResult['streakDays'] ?? 0;

      final dueCount = (results[1].data['result'] as num?)?.toInt() ?? 0;

      final upcomingRaw = results[2].data['result'];
      _comingUpCards = (upcomingRaw is List)
          ? upcomingRaw
                .whereType<Map>()
                .map(
                  (e) =>
                      StudyCardResponse.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [];

      StudySessionResponse? sessionData;
      if (dueCount > 0) {
        final dailyReviewRes = await api.post('/api/study/daily-review');
        sessionData = StudySessionResponse.fromJson(
          dailyReviewRes.data['result'] as Map<String, dynamic>,
        );
      }

      if (!mounted) return;
      setState(() {
        _sessionData = sessionData;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startReview() {
    if (_sessionData == null || _sessionData!.cards.isEmpty) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => StudyScreen(sessionData: _sessionData),
          ),
        )
        .then((result) {
          if (mounted) {
            // Always refetch data when returning from study screen
            _loadData();
            // Pop back to home with refresh flag if study was completed
            if (result == true) {
              Navigator.of(context).pop(true);
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // bg-background-light
      body: _loading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Unable to load review list',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.lexend(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final cards = _sessionData?.cards ?? [];
    final totalCards = cards.length;
    final upcomingCards = _comingUpCards
        .where((c) => !_containsCard(cards, c.cardId))
        .toList();

    return Column(
      children: [
        // ── HEADER ──
        _buildHeader(totalCards),

        // ── CARD LIST ──
        Expanded(
          child: cards.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  children: [
                    // Stats card
                    _buildStatsCard(totalCards),
                    const SizedBox(height: 24),

                    // Ready Now section
                    _buildSectionHeader(
                      'Ready Now',
                      totalCards.toString(),
                      const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    ...cards.map((card) => _buildCardItem(card, isReady: true)),

                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      'Coming Up Later',
                      upcomingCards.length.toString(),
                      const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 12),
                    if (upcomingCards.isEmpty)
                      _buildNoUpcomingHint()
                    else
                      ...upcomingCards.map(
                        (card) => _buildCardItem(card, isReady: false),
                      ),
                  ],
                ),
        ),

        // ── BOTTOM BUTTON ──
        if (cards.isNotEmpty) _buildBottomButton(totalCards),
      ],
    );
  }

  Widget _buildHeader(int totalCards) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button & filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderIconButton(
                Icons.arrow_back_rounded,
                () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Upcoming Reviews',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep up the momentum!',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildStatsCard(int totalCards) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Due Today section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DUE TODAY',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$totalCards',
                      style: GoogleFonts.lexend(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'cards',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Streak & Goal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Orange 50
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFED7AA), // Orange 200
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFF97316), // Orange 500
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_streakDays day streak',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(StudyCardResponse card, {required bool isReady}) {
    final timeLabel = !isReady ? _formatTimeUntil(card.nextReviewAt) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Word info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.front,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (card.phonetic != null && card.phonetic!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    card.phonetic!,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Status badge
          if (isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4), // Green 50
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBF7D0)), // Green 200
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF22C55E), // Green 500
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'READY',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF22C55E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          if (!isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Color(0xFFF97316),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeLabel ?? 'SOON',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF97316),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoUpcomingHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Text(
        'No upcoming cards in the next 3 hours.',
        style: GoogleFonts.lexend(
          fontSize: 13,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: const Color(0xFF22C55E).withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'All Caught Up!',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No cards due for review right now.\nGreat job keeping up!',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          'Coming Up Later',
          _comingUpCards.length.toString(),
          const Color(0xFFF97316),
        ),
        const SizedBox(height: 12),
        if (_comingUpCards.isEmpty)
          _buildNoUpcomingHint()
        else
          ..._comingUpCards.map((card) => _buildCardItem(card, isReady: false)),
      ],
    );
  }

  Widget _buildBottomButton(int totalCards) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _startReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start Review Session',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalCards',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _containsCard(List<StudyCardResponse> cards, String cardId) {
    for (final card in cards) {
      if (card.cardId == cardId) return true;
    }
    return false;
  }

  String? _formatTimeUntil(String? nextReviewAt) {
    if (nextReviewAt == null || nextReviewAt.isEmpty) return null;

    final parsed = DateTime.tryParse(nextReviewAt);
    if (parsed == null) return null;

    final now = DateTime.now();
    final diff = parsed.difference(now);
    if (diff.inMinutes <= 1) return 'SOON';
    if (diff.inMinutes < 60) return 'IN ${diff.inMinutes}M';

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (minutes == 0) return 'IN ${hours}H';
    return 'IN ${hours}H ${minutes}M';
  }
}
