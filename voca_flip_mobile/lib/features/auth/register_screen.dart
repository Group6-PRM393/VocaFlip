import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/auth/constants/password_constants.dart';
import 'package:voca_flip_mobile/features/auth/otp_verification_screen.dart';
import 'package:voca_flip_mobile/features/auth/providers/auth_provider.dart';
import 'package:voca_flip_mobile/features/auth/utils/password_strength_utils.dart';
import 'package:voca_flip_mobile/features/auth/widgets/auth_text_field.dart';
import 'package:voca_flip_mobile/features/auth/widgets/google_sign_in_button.dart';
import 'package:voca_flip_mobile/features/auth/widgets/password_strength_section.dart';
import 'package:voca_flip_mobile/features/auth/widgets/register_hero_illustration.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  PasswordStrengthResult get _passwordStrength =>
      PasswordStrengthEvaluator.evaluate(_passwordController.text);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: _emailController.text.trim(),
            flow: OtpFlow.emailVerification,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.status == AuthStatus.failure && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Register',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // ── Illustration ──
                const RegisterHeroIllustration(),

                const SizedBox(height: 20),

                // ── Heading ──
                Text(
                  'Join VocaFlip',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.authHeroTitle.copyWith(
                    fontSize: 30, // text-3xl
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your journey to better vocabulary starts here.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.authHeroSubtitle,
                ),
                const SizedBox(height: 28),

                // ── Full Name ──
                const AuthFieldLabel(label: 'Full Name'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _nameController,
                  hintText: 'John Doe',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AuthMessages.requiredFullName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Email Address ──
                const AuthFieldLabel(label: 'Email Address'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'hello@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AuthMessages.requiredEmail;
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return AuthMessages.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password ──
                const AuthFieldLabel(label: 'Password'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  onChanged: (_) => setState(() {}),
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AuthMessages.requiredPassword;
                    }
                    final strength = PasswordStrengthEvaluator.evaluate(v);
                    if (!strength.isValid) {
                      return AuthMessages.passwordRequirementSummary;
                    }
                    if (v.length >= PasswordConstants.maxLength) {
                      return AuthMessages.passwordTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                PasswordStrengthSection(
                  result: _passwordStrength,
                  guideText: PasswordConstants.strengthGuideText,
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ──
                const AuthFieldLabel(label: 'Confirm Password'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  onChanged: (_) => setState(() {}),
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AuthMessages.requiredConfirmPassword;
                    }
                    if (v != _passwordController.text) {
                      return AuthMessages.passwordMismatch;
                    }
                    if (v.length >= PasswordConstants.maxLength) {
                      return AuthMessages.passwordTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Sign Up button ──
                _SignUpButton(isLoading: isLoading, onPressed: _onSignUp),
                const SizedBox(height: 22),

                // ── Divider ──
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.googleBorder),
                    ), // border-gray-200
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.googleBorder),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Google button ──
                GoogleSignInButton(
                  onPressed: () {
                    // TODO: implement Google sign-in
                  },
                ),
                const SizedBox(height: 28),

                // ── Log In link ──
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Sub-widgets (Local)
// ─────────────────────────────────────────────────────

class _SignUpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _SignUpButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // h-12 from tailwind
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // rounded-xl
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.2,
            ), // shadow-primary/20
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 18, // text-lg
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}
