import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/profile/providers/user_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  static const _specialCharacters = r'''!@#$%^&*(),.?":{}|<>_-+=~`[]\/;''';

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _confirmPasswordError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Các điều kiện kiểm tra áp dụng cho Mật khẩu mới (New Password)
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);
  bool get _hasSpecialCharacter =>
      _newPasswordController.text.split('').any(_specialCharacters.contains);

  int get _strengthScore {
    var score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasSpecialCharacter) score++;
    if (_newPasswordController.text.length >= 12) score++;
    return score;
  }

  String get _strengthLabel {
    if (_strengthScore <= 1) return 'Weak';
    if (_strengthScore <= 3) return 'Medium';
    return 'Strong';
  }

  Color get _strengthColor {
    if (_strengthScore <= 1) return AppColors.buttonForgot;
    if (_strengthScore <= 3) return AppColors.primary;
    return Colors.green;
  }

  Future<void> _onChangePassword() async {
    if (_isSubmitting) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _confirmPasswordError = null;
    });

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.redAccent);
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = 'Mật khẩu xác nhận không khớp');
      return;
    }

    if (!_hasMinLength || !_hasUppercase || !_hasSpecialCharacter) {
      _showSnackBar('Mật khẩu mới chưa đạt yêu cầu', Colors.redAccent);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = await ref.read(userRepositoryProvider.future);
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;
      _showSnackBar('Đổi mật khẩu thành công', Colors.green);
      Navigator.pop(context, true); // Quay về và kèm kết quả
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
              'Change Password',
              textAlign: TextAlign.center,
              style: AppTextStyles.authTopBarTitle,
            ),
          ),
          const SizedBox(width: 48), // Cân bằng không gian với IconButton
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

  Widget _buildStrengthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _strengthLabel,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isActive = index < _strengthScore;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isActive ? _strengthColor : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
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
            satisfied: _hasMinLength,
          ),
          const SizedBox(height: 10),
          _buildRequirementItem(
            text: 'One uppercase character',
            satisfied: _hasUppercase,
          ),
          const SizedBox(height: 10),
          _buildRequirementItem(
            text: 'One special character',
            satisfied: _hasSpecialCharacter,
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
                'Update your password',
                style: AppTextStyles.authScreenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your current password and create a new secure password.',
                style: AppTextStyles.authScreenBody,
              ),
              const SizedBox(height: 32),

              // --- Current Password ---
              _buildPasswordField(
                label: 'Current Password',
                hintText: 'Enter current password',
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                onChanged: (_) {},
                onToggleVisibility: () {
                  setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- New Password ---
              _buildPasswordField(
                label: 'New Password',
                hintText: 'Enter new password',
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                onChanged: (_) {
                  setState(() {}); // Trigger build to update strength UI
                },
                onToggleVisibility: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
              ),
              const SizedBox(height: 20),
              _buildStrengthSection(),
              const SizedBox(height: 24),

              // --- Confirm New Password ---
              _buildPasswordField(
                label: 'Confirm New Password',
                hintText: 'Re-enter new password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  if (_confirmPasswordError != null) {
                    setState(() => _confirmPasswordError = null);
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
          onPressed: _isSubmitting ? null : _onChangePassword,
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
