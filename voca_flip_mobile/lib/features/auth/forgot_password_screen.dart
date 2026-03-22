import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/auth/otp_verification_screen.dart';
import 'package:voca_flip_mobile/features/auth/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  static const _horizontalPadding = 24.0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final success = await ref
        .read(authProvider.notifier)
        .requestOtp(email: email);

    if (!mounted || !success) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            OtpVerificationScreen(email: email, flow: OtpFlow.passwordReset),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthMessages.requiredEmail;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return AuthMessages.invalidEmail;
    }

    return null;
  }

  InputDecoration _emailDecoration() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.stitchAuthBorder),
    );

    return InputDecoration(
      hintText: 'example@email.com',
      hintStyle: GoogleFonts.lexend(color: AppColors.textHint, fontSize: 16),
      prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildTopBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          iconSize: 28,
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.authHeroBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: AppTextStyles.authScreenTitle,
        ),
        const SizedBox(height: 10),
        Text(
          "Don't worry! It happens. Please enter the email address associated with your account.",
          textAlign: TextAlign.center,
          style: AppTextStyles.authScreenBody,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Email Address', style: AppTextStyles.authScreenLabel),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.authScreenInput,
          decoration: _emailDecoration(),
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildSubmitButton({required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.textOnPrimary,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Send Reset Link',
                style: GoogleFonts.lexend(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  12,
                  _horizontalPadding,
                  24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHero(),
                      const SizedBox(height: 34),
                      _buildEmailField(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(isLoading: isLoading),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
