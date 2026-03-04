import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/modules/quiz/screens/quiz_settings_screen.dart';
import '../../constants/app_colors.dart';
import '../home/home_tab.dart';
import '../category/category_management_screen.dart';
import '../profile/user_profile_screen.dart';

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

  /* Code ban đầu của Huy
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      default:
        // Cập nhật phần này để hiển thị nút Test Quiz ở các tab 1, 2, 3
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Coming soon...',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20), // Khoảng cách giữa chữ và nút
              // --- NÚT TEST QUIZ CỦA BẠN ĐÂY ---
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizSettingsScreen(
                        deckId:
                            "deck-test", // THAY BẰNG ID DECK CÓ THẬT TRONG DB CỦA BẠN
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Vào Test Quiz",
                  style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                ),
              ),
              // ---------------------------------
            ],
          ),
        );
    }
  }
  */

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
    if (_selectedIndex == 3 || _selectedIndex == 4) return null;
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thông báo',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Chức năng Tạo Deck đang được triển khai',
              style: GoogleFonts.lexend(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'OK',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
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
              _navItem(3, Icons.category_rounded, 'Category'), //Đông thêm Category
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
