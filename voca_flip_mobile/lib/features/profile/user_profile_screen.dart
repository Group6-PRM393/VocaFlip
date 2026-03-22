import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/auth/login_screen.dart';
import 'package:voca_flip_mobile/features/auth/providers/auth_provider.dart';
import 'package:voca_flip_mobile/features/profile/edit_profile_screen.dart';
import 'package:voca_flip_mobile/features/profile/change_password_screen.dart';
import 'package:voca_flip_mobile/features/profile/providers/user_provider.dart';
import 'package:voca_flip_mobile/features/auth/models/auth_model.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  // Màu sắc theo Tailwind config từ HTML
  final Color primaryColor = const Color(0xFF135bec);
  final Color textDark = const Color(0xFF111318);
  final Color surfaceLight = const Color(0xFFf6f6f8);
  final Color backgroundLight = const Color(0xFFffffff);

  // Các hàm điều hướng
  void _navigateToEditProfile(UserModel currentUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: currentUser),
      ),
    ).then((updated) async {
      if (updated == true) {
        // Refresh API lại sau khi sửa xong Profile
        ref.invalidate(currentUserProfileProvider);
        try {
          await ref.read(currentUserProfileProvider.future);
        } catch (_) {}
      }
    });
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Dùng provider lấy Data từ backend
    final userAsyncValue = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2, // tracking-[-0.015em]
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              onTap: () {
                if (userAsyncValue.hasValue) {
                  _navigateToEditProfile(userAsyncValue.value!);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: userAsyncValue.when(
        loading: () => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor,
                const Color(0xFF4a82f4),
                Colors.blue.shade50.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (user) {
          final avatarUrl =
              user.avatarUrl ??
              'https://ui-avatars.com/api/?name=${user.name.replaceAll(' ', '+')}&background=random';

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER GRADIENT & PROFILE INFO ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top:
                        MediaQuery.of(context).padding.top +
                        32, // Khoảng cách từ Appbar
                    bottom: 80, // pb-20
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor,
                        const Color(0xFF4a82f4),
                        Colors.blue.shade50.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Avatar kèm status online
                      Stack(
                        children: [
                          Container(
                            width: 112, // h-28 w-28
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80), // bg-green-400
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tên & Email
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24, // text-2xl
                          fontWeight: FontWeight.bold,
                          height: 1.25, // leading-tight
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14, // text-sm
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- MAIN CONTENT (-mt-16) ---
                Transform.translate(
                  offset: const Offset(0, -64), // Tương đương -mt-16
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 448,
                      ), // max-w-md
                      child: Column(
                        children: [
                          // 1. STATS GRID (3 Cột)
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '${user.totalWords ?? 0}',
                                  'Total Words',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDayStreakCard(
                                  '${user.streakDays ?? 0}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  '${user.masteredWords ?? 0}',
                                  'Mastered',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // 2. CHANGE PASSWORD BUTTON
                          InkWell(
                            onTap: _navigateToChangePassword,
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // rounded-2xl
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.05,
                                    ), // shadow-sm
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, // size-12
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50, // bg-blue-50
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ), // rounded-xl
                                    ),
                                    child: Icon(
                                      Icons.lock,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Change Password',
                                          style: TextStyle(
                                            color: textDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Update your security credentials',
                                          style: TextStyle(
                                            color: Colors
                                                .grey
                                                .shade500, // text-gray-500
                                            fontSize: 12, // text-xs
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color:
                                        Colors.grey.shade400, // text-gray-400
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 3. LOG OUT BUTTON
                          InkWell(
                            onTap: () async {
                              await ref.read(authProvider.notifier).logout();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (_) => false,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16), // p-4
                              decoration: BoxDecoration(
                                color: Colors.red.shade50, // bg-red-50
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // rounded-2xl
                                border: Border.all(
                                  color: Colors.red.shade100, // border-red-100
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Log Out',
                                    style: TextStyle(
                                      color:
                                          Colors.red.shade600, // text-red-600
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w600, // font-semibold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          // Version Text
                          Text(
                            'VocaFlip Version 1.0.0',
                            style: TextStyle(
                              color: Colors.grey.shade400, // text-gray-400
                              fontSize: 12, // text-xs
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Card bình thường
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16), // p-4
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // rounded-2xl
        border: Border.all(color: Colors.blue.shade50), // border-blue-50
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(19, 91, 236, 0.15), // shadow-soft-blue
            blurRadius: 40,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: primaryColor,
              fontSize: 20, // text-xl
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500, // text-gray-500
              fontSize: 12, // text-xs
              fontWeight: FontWeight.w500, // font-medium
            ),
          ),
        ],
      ),
    );
  }

  // Card Streak có hình ngọn lửa
  Widget _buildDayStreakCard(String value) {
    return Container(
      padding: const EdgeInsets.all(16), // p-4
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(19, 91, 236, 0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background icon fire
          Positioned(
            top: -12,
            right: -12,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade500,
                size: 48,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade500,
                    size: 16, // text-base
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Day Streak',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
