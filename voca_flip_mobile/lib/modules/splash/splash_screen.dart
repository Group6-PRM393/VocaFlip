import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Start real initialization
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Animate loading bar
    _loadingController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );

    // Delay for splash screen effect
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check login status
    final authRepo = ref.read(authRepositoryProvider);
    final isLoggedIn = authRepo.isLoggedIn;

    // Navigate based on authentication status
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgDark, // bg-blue-900 base
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.splashBgDark, // from-blue-900
                  AppColors.splashBgMid, // via-blue-700
                  AppColors.splashBgLight, // to-blue-500
                ],
              ),
            ),
          ),

          // 2. Dotted overlay simulation
          CustomPaint(
            painter: _DottedBackgroundPainter(
              color: Colors.white.withValues(alpha: 0.07),
              spacing: 24,
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  // Center: Logo & Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rotating Cards Logo
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: -12 * 3.14159 / 180,
                              child: _buildCard(
                                Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            Transform.rotate(
                              angle: -6 * 3.14159 / 180,
                              child: _buildCard(
                                Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            Transform.rotate(
                              angle: 0,
                              child: Container(
                                height: 96,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 15,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.style_rounded,
                                    size: 48,
                                    color: AppColors.splashBgMid,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Texts
                      Text('VocaFlip', style: AppTextStyles.splashTitle),
                      const SizedBox(height: 12),
                      Text(
                        'Master English Vocabulary',
                        style: AppTextStyles.splashSubtitle,
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Bottom: Loading Bar
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 6,
                        width: 192, // w-48
                        decoration: BoxDecoration(
                          color: AppColors.splashLoadingBg.withValues(
                            alpha: 0.3,
                          ), // blue-950/30
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _loadingController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: _loadingController.value,
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('LOADING', style: AppTextStyles.splashLoading),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Color color) {
    return Container(
      height: 96,
      width: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _DottedBackgroundPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBackgroundPainter oldDelegate) {
    return color != oldDelegate.color || spacing != oldDelegate.spacing;
  }
}
