import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/profile/providers/user_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final Color primaryColor = const Color(0xFF135BEC);
  final Color backgroundLight = const Color(0xFFF6F6F8);
  final Color textDark = const Color(0xFF0F172A); // slate-900
  final Color textGray = const Color(0xFF64748B); // slate-500

  // Quản lý trạng thái Ẩn/Hiện mật khẩu cho 3 ô riêng biệt
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ các trường')),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới phải từ 8 ký tự trở lên')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = await ref.read(userRepositoryProvider.future);
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công')),
      );
      Navigator.pop(context, true); // Quay về và kèm kết quả
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Theo HTML thì dùng thẻ card màu trắng
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2, // shadow-md
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5, // tracking-wide
          ),
        ),
      ),
      body: Column(
        children: [
          // Dùng Expanded + SingleChildScrollView để ô nhập có thể cuộn khi bật bàn phím, 
          // còn nút bấm luôn nằm ở dưới cùng.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Intro Text ---
                  Center(
                    child: Text(
                      'Update your password to keep your VocaFlip account secure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textGray, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 1. Current Password ---
                  _buildPasswordField(
                    label: 'Current Password',
                    hint: 'Enter current password',
                    controller: _currentPasswordController,
                    isObscure: _obscureCurrent,
                    onToggleVisibility: () {
                      setState(() => _obscureCurrent = !_obscureCurrent);
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- 2. New Password ---
                  _buildPasswordField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: _newPasswordController,
                    isObscure: _obscureNew,
                    onToggleVisibility: () {
                      setState(() => _obscureNew = !_obscureNew);
                    },
                  ),
                  
                  // Meta Text / Helper dưới ô New Password
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade400, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Must be at least 8 characters long.',
                            style: TextStyle(color: textGray, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 3. Confirm New Password ---
                  _buildPasswordField(
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    controller: _confirmPasswordController,
                    isObscure: _obscureConfirm,
                    onToggleVisibility: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- Action Button (Luôn nằm ở đáy) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), // pb-8 để tránh bị lẹm vào safe area của iPhone
            child: SizedBox(
              width: double.infinity,
              height: 56, // h-14
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: primaryColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // rounded-xl
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Update Password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM TẠO Ô NHẬP MẬT KHẨU DÙNG CHUNG ---
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(color: textDark, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // Nút hình con mắt
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: onToggleVisibility,
              splashRadius: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}