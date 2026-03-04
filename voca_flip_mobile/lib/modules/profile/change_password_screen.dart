import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final Color primaryColor = const Color(0xFF135BEC);
  final Color backgroundLight = const Color(0xFFF6F6F8);
  final Color textDark = const Color(0xFF0F172A); // slate-900
  final Color textGray = const Color(0xFF64748B); // slate-500

  // Quản lý trạng thái Ẩn/Hiện mật khẩu cho 3 ô riêng biệt
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
                            'Must be at least 8 characters long and include numbers.',
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
                onPressed: () {
                  print("Xử lý đổi mật khẩu");
                  Navigator.pop(context); // Quay về sau khi đổi xong
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // rounded-xl
                  ),
                ),
                child: const Text(
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