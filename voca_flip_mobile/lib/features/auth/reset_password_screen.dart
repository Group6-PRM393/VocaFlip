import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/auth/constants/password_constants.dart';
import 'package:voca_flip_mobile/features/auth/login_screen.dart';
import 'package:voca_flip_mobile/features/auth/providers/auth_provider.dart';
import 'package:voca_flip_mobile/features/auth/utils/password_strength_utils.dart';
import 'package:voca_flip_mobile/features/auth/widgets/password_strength_section.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _confirmPasswordError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  PasswordStrengthResult get _passwordStrength =>
      PasswordStrengthEvaluator.evaluate(_passwordController.text);

  Future<void> _onUpdatePassword() async {
    if (_isSubmitting) return;

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _confirmPasswordError = null;
    });

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all required fields.', Colors.redAccent);
      return;
    }

    if (password != confirmPassword) {
      setState(
        () => _confirmPasswordError = 'Confirmation password does not match.',
      );
      return;
    }

    if (!_passwordStrength.isValid) {
      _showSnackBar(
        'Password does not meet the requirements.',
        Colors.redAccent,
      );
      return;
    }

    if (password.length >= PasswordConstants.maxLength) {
      _showSnackBar(AuthMessages.passwordTooLong, Colors.redAccent);
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(
          email: widget.email,
          otpCode: widget.otpCode,
          newPassword: password,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      final errorMessage = ref.read(authProvider).errorMessage;
      _showSnackBar(
        errorMessage ?? AuthMessages.resetPasswordFailed,
        Colors.redAccent,
      );
      return;
    }

    _showSnackBar(AuthMessages.resetPasswordSuccess, Colors.green);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => route.isFirst,
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              'Reset Password',
              textAlign: TextAlign.center,
              style: AppTextStyles.authTopBarTitle,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.authLabel.copyWith(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.imageOverlay,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText == null
                  ? AppColors.inputBorder
                  : Colors.redAccent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: AppTextStyles.authScreenInput,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.authScreenInput.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: AppTextStyles.caption.copyWith(
              color: Colors.redAccent,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRequirementItem({
    required String text,
    required bool satisfied,
  }) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: satisfied ? Colors.green : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.imageOverlay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements:',
            style: AppTextStyles.authLabel.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            text: 'At least 8 characters',
            satisfied: _passwordStrength.hasMinLength,
          ),
          const SizedBox(height: 10),
          _buildRequirementItem(
            text: 'One uppercase character',
            satisfied: _passwordStrength.hasUppercase,
          ),
          const SizedBox(height: 10),
          _buildRequirementItem(
            text: 'One special character',
            satisfied: _passwordStrength.hasSpecialCharacter,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Container(
        color: AppColors.cardBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a strong password',
                style: AppTextStyles.authScreenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Your new password must be different from previously used passwords.',
                style: AppTextStyles.authScreenBody,
              ),
              const SizedBox(height: 32),
              _buildPasswordField(
                label: 'New Password',
                hintText: 'Enter new password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) {
                  setState(() {});
                },
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 20),
              PasswordStrengthSection(
                result: _passwordStrength,
                guideText: PasswordConstants.strengthGuideText,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'Confirm New Password',
                hintText: 'Re-enter password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  if (_confirmPasswordError != null) {
                    setState(() => _confirmPasswordError = null);
                  } else {
                    setState(() {});
                  }
                },
                onToggleVisibility: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildRequirementsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _onUpdatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Update Password',
                      style: AppTextStyles.authScreenLabel.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [_buildTopBar(), _buildContent(), _buildBottomAction()],
            ),
          ),
        ),
      ),
    );
  }
}
