import 'package:flutter/material.dart';

import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.googleBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleGLogoFallback(),
            const SizedBox(width: 12),
            Text(
              'Sign in with Google',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.googleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGLogoFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final segments = [
      {'color': const Color(0xFF4285F4), 'start': -30.0, 'sweep': 90.0},
      {'color': const Color(0xFFEA4335), 'start': 60.0, 'sweep': 120.0},
      {'color': const Color(0xFFFBBC05), 'start': 180.0, 'sweep': 60.0},
      {'color': const Color(0xFF34A853), 'start': 240.0, 'sweep': 90.0},
    ];

    for (final seg in segments) {
      paint.color = seg['color'] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _deg(seg['start'] as double),
        _deg(seg['sweep'] as double),
        true,
        paint,
      );
    }

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.65, paint);

    paint.color = Colors.white;
    final rectH = radius * 0.35;
    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - rectH / 2,
          center.dx + radius + 2, center.dy + rectH / 2),
      paint,
    );
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - rectH / 2,
          center.dx + radius * 0.9, center.dy + rectH / 2),
      paint,
    );
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.62, paint);
  }

  double _deg(double deg) => deg * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
