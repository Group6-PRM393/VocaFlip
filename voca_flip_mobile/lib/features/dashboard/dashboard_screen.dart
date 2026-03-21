import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/features/dashboard/learning_progress_stats_screen.dart';
import 'package:voca_flip_mobile/features/dashboard/widgets/dashboard_bottom_nav.dart';
import 'package:voca_flip_mobile/features/dashboard/widgets/dashboard_fab.dart';
import 'package:voca_flip_mobile/features/profile/learning_history_activity_screen.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/features/deck/screens/create_deck_screen.dart';
import 'package:voca_flip_mobile/features/home/home_tab.dart';
import 'package:voca_flip_mobile/features/category/category_management_screen.dart';
import 'package:voca_flip_mobile/features/profile/user_profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openCreateDeck() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateDeckScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _selectedIndex == 0
          ? DashboardFab(onPressed: _openCreateDeck)
          : null,
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const LearningHistoryActivityScreen();
      case 2:
        return const LearningProgressStatsScreen();
      case 3:
        return const CategoryManagementScreen();
      case 4:
        return const UserProfileScreen();
      default:
        return Center(
          child: Text(
            'Coming soon...',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        );
    }
  }
}
