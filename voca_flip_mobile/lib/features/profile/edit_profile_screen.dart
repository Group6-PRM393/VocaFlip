import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voca_flip_mobile/features/auth/models/auth_model.dart';
import 'package:voca_flip_mobile/features/profile/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // ── Màu sắc ──────────────────────────────────────────────────────────────
  final Color primaryColor = const Color(0xFF1337EC);
  final Color backgroundLight = const Color(0xFFF6F6F8);
  final Color textDark = const Color(0xFF111218);

  // ── State ─────────────────────────────────────────────────────────────────
  late TextEditingController _nameController;
  XFile? _pickedImageXFile;
  Uint8List? _pickedImageBytes;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Chọn ảnh từ Gallery hoặc Camera ──────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85, // nén nhẹ để giảm dung lượng upload
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      setState(() {
        _pickedImageXFile = picked;
        _pickedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
    }
  }

  // ── Bottom sheet chọn nguồn ảnh ──────────────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Chọn ảnh đại diện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.photo_library_rounded, color: primaryColor),
                ),
                title: const Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.camera_alt_rounded, color: primaryColor),
                ),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              // Chỉ hiện nút xoá nếu đang có ảnh đã chọn (chưa lưu)
              if (_pickedImageBytes != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEB),
                    child: Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text(
                    'Huỷ ảnh vừa chọn',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pickedImageXFile = null;
                      _pickedImageBytes = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Lưu thay đổi ─────────────────────────────────────────────────────────
  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repo = await ref.read(userRepositoryProvider.future);

      // 1. Nếu người dùng chọn ảnh mới → upload trước
      if (_pickedImageBytes != null) {
        await repo.uploadAvatar(
          bytes: _pickedImageBytes!,
          fileName: _pickedImageXFile?.name,
        );
      }

      // 2. Cập nhật tên (avatarUrl được quản lý riêng qua endpoint /me/avatar)
      await repo.updateProfile(name: name);

      if (!mounted) return;
      Navigator.pop(context, true); // true → màn ngoài biết cần refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Ưu tiên hiển thị ảnh mới được chọn; fallback về avatar cũ / generated
    final fallbackAvatarUrl =
        widget.user.avatarUrl ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.user.name)}&background=random';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 24),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── MAIN CONTENT ──────────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Avatar Section ────────────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      // Avatar circle
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              spreadRadius: 1,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _pickedImageBytes != null
                              // Xem trước ảnh mới chọn từ thiết bị
                              ? Image.memory(
                                  _pickedImageBytes!,
                                  fit: BoxFit.cover,
                                  width: 128,
                                  height: 128,
                                )
                              // Ảnh hiện tại từ server
                              : Image.network(
                                  fallbackAvatarUrl,
                                  fit: BoxFit.cover,
                                  width: 128,
                                  height: 128,
                                  loadingBuilder: (_, child, progress) =>
                                      progress == null
                                      ? child
                                      : const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                        ),
                      ),

                      // Badge "ảnh mới" nếu đang có ảnh chưa lưu
                      if (_pickedImageBytes != null)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Mới',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Camera button
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.photo_camera,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hint text khi có ảnh mới chưa lưu
                if (_pickedImageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Ảnh sẽ được lưu khi bạn nhấn "Save Changes"',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // ── Form Section ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: textDark, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 16,
                          ),
                          suffixIcon: Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFDBDDE6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── FIXED BOTTOM BUTTON ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.blue.withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
