import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color primaryColor = const Color(0xFF1337EC);
  final Color backgroundLight = const Color(0xFFF6F6F8);
  final Color textDark = const Color(0xFF111218);

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị mặc định lấy từ HTML
    _nameController = TextEditingController(text: 'Sarah Johnson');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Giao diện HTML dùng nền trắng cho phần lớn content
      
      // --- HEADER ---
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
            letterSpacing: -0.2, // tracking-[-0.015em]
          ),
        ),
      ),

      // Dùng Stack để đè phần nút Save Changes mờ (backdrop-blur) xuống đáy
      body: Stack(
        children: [
          // --- MAIN CONTENT ---
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Chừa chỗ cho nút Save
            child: Column(
              children: [
                const SizedBox(height: 32), // p-8 top padding

                // 1. Avatar Section
                Center(
                  child: Stack(
                    children: [
                      // Avatar Image
                      Container(
                        width: 128, // w-32
                        height: 128, // h-32
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200, // ring-gray-100
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                          image: const DecorationImage(
                            // Dùng URL ngẫu nhiên thay cho googleusercontent (tránh lỗi 403)
                            image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Camera Icon Button
                      Positioned(
                        bottom: 4, // bottom-0 right-1 (ước lượng)
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            print("Mở thư viện ảnh hoặc camera");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10), // p-2.5
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15), // shadow-md
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
                const SizedBox(height: 32),

                // 2. Form Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24), // px-6
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6), // ml-1, gap-1.5
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 14, // text-sm
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // TextField
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: textDark, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16), // h-14, px-[15px]
                          suffixIcon: Icon(Icons.person, color: Colors.grey.shade400, size: 22),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), // rounded-lg
                            borderSide: const BorderSide(color: Color(0xFFDBDDE6)), // border-[#dbdde6]
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryColor, width: 2), // focus:border-primary focus:ring-2
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- FIXED BOTTOM BUTTON ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20), // p-5
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // bg-white/90
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48, // h-12
                child: ElevatedButton(
                  onPressed: () {
                    print("Đã lưu tên: ${_nameController.text}");
                    Navigator.pop(context); // Trở về màn trước
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.25), // shadow-blue-500/25
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // rounded-xl
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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