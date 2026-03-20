import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/features/quiz/screens/quiz_settings_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return Center(
          child: Text(
            'Coming soon...',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        );
      case 2:
        return Center(
          child: Text(
            'Coming soon...',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        );
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

  Widget? _buildFab() {
    // Chỉ hiện nút "+" tạo deck trên tab Home (index 0)
    if (_selectedIndex != 0) return null;
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateDeckScreen()),
        );
      },
      backgroundColor: AppColors.primary,
      elevation: 8,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.history_rounded, 'History'),
              _navItem(2, Icons.bar_chart_rounded, 'Stats'),
              _navItem(
                3,
                Icons.category_rounded,
                'Category',
              ), //Đông thêm Category
              _navItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
