import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';

class RegisterHeroIllustration extends StatelessWidget {
  const RegisterHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(26, 255, 255, 255),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background tint
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
            // The illustration image
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCglfAEqfbUUGIlOthXiqT-qWfCoXYPHtpFOcIM52vY3JJoy7bT-Se-x82nwkakTZkWOVg9pw0R99ZUt7qBOKiV-lchASJ97loVTxEbNbEyQ7mVaaRjJAbNGqyVltnn0MrZsr-4eKosHpyGAiEhmqJfQHirRmge4kFgpbqKvmK-n75FPbDzLgcNRpnvW_dLnLHIJ95_6j4WEC1vULtKdb_er0Y__jnBKhD48Xn3O6_R4J-omkvm_vLyhREDruZhjotfroYFjDIFV4sj',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
