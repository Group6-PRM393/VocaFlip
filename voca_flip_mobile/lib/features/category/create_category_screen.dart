// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:voca_flip_mobile/core/constants/app_colors.dart';
// import 'package:voca_flip_mobile/features/category/models/category_model.dart';
// import 'package:voca_flip_mobile/core/utils/category_helper.dart';

// class CreateCategoryScreen extends StatefulWidget {
//   const CreateCategoryScreen({super.key});

//   @override
//   State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
// }

// class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
//   final TextEditingController _nameController = TextEditingController();

//   // Danh sách Icon Code (Giống y hệt HTML)
//   final List<String> iconCodes = [
//     'menu_book', 'school', 'work', 'flight', 
//     'restaurant', 'forum', 'star', 'flag'
//   ];
//   int selectedIconIndex = 0;

//   // Danh sách Color Hex (Dựa theo các màu Tailwind 200 trong HTML)
//   final List<String> colorHexes = [
//     '#BFDBFE', // blue-200
//     '#FECACA', // red-200
//     '#BBF7D0', // green-200
//     '#FEF08A', // yellow-200
//     '#E9D5FF', // purple-200
//     '#FED7AA', // orange-200
//     '#99F6E4', // teal-200
//   ];
//   int selectedColorIndex = 0;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
      
//       // --- HEADER ---
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 2,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'New Category',
//           style: GoogleFonts.lexend(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//       ),

//       // --- BODY ---
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 120), // Chừa chỗ cho nút Create
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 1. Nhập Tên Category
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Category Name',
//                         style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
//                       ),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: _nameController,
//                         style: GoogleFonts.lexend(color: AppColors.textPrimary),
//                         decoration: InputDecoration(
//                           hintText: 'e.g., Business English',
//                           hintStyle: GoogleFonts.lexend(color: AppColors.textHint),
//                           filled: true,
//                           fillColor: AppColors.cardBackground,
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: AppColors.divider),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: AppColors.primary, width: 2),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // 2. Chọn Icon
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                   child: Text(
//                     'Choose an Icon',
//                     style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: iconCodes.length,
//                     itemBuilder: (context, index) {
//                       final isSelected = index == selectedIconIndex;
//                       final iconData = CategoryHelper.getIconFromString(iconCodes[index]);
                      
//                       return GestureDetector(
//                         onTap: () => setState(() => selectedIconIndex = index),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           decoration: BoxDecoration(
//                             color: isSelected ? AppColors.primary : AppColors.cardBackground,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isSelected ? AppColors.primary : AppColors.divider,
//                             ),
//                             boxShadow: isSelected
//                                 ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
//                                 : [],
//                           ),
//                           child: Icon(
//                             iconData,
//                             color: isSelected ? Colors.white : AppColors.textHint,
//                             size: 32,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // 3. Chọn Màu sắc
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                   child: Text(
//                     'Label Color',
//                     style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 60,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     itemCount: colorHexes.length,
//                     itemBuilder: (context, index) {
//                       final isSelected = index == selectedColorIndex;
//                       final colorValue = CategoryHelper.hexToColor(colorHexes[index]);
                      
//                       return GestureDetector(
//                         onTap: () => setState(() => selectedColorIndex = index),
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 16),
//                           width: 48, height: 48,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
//                           ),
//                           child: Center(
//                             child: Container(
//                               width: isSelected ? 38 : 48,
//                               height: isSelected ? 38 : 48,
//                               decoration: BoxDecoration(
//                                 color: colorValue,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: isSelected
//                                   ? const Icon(Icons.check, color: AppColors.primary, size: 24)
//                                   : null,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // --- FIXED BOTTOM BUTTON ---
//           Positioned(
//             bottom: 0, left: 0, right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     AppColors.scaffoldBackground,
//                     AppColors.scaffoldBackground.withValues(alpha: 0.9),
//                     AppColors.scaffoldBackground.withValues(alpha: 0.0),
//                   ],
//                 ),
//               ),
//               child: ElevatedButton(
//                 onPressed: () {
//                   final categoryName = _nameController.text.trim();
//                   if (categoryName.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
//                     );
//                     return;
//                   }

//                   // Tạo 1 Model chứa dữ liệu người dùng nhập
//                   final newCategoryData = CategoryModel(
//                     categoryName: categoryName,
//                     iconCode: iconCodes[selectedIconIndex],
//                     colorHex: colorHexes[selectedColorIndex],
//                   );

//                   // Gửi trả dữ liệu về màn Quản lý để gọi API
//                   Navigator.pop(context, newCategoryData);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   elevation: 5,
//                   shadowColor: AppColors.primary.withValues(alpha: 0.3),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Create Category', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                     const SizedBox(width: 8),
//                     const Icon(Icons.add_circle, color: Colors.white),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Tên file: lib/create_category_screen.dart
import 'package:flutter/material.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final Color primaryColor = const Color(0xFF135BEC);
  final Color backgroundLight = const Color(0xFFF6F6F8);
  
  // Danh sách Icons
  final List<IconData> categoryIcons = [
    Icons.menu_book, Icons.school, Icons.work, Icons.flight,
    Icons.restaurant, Icons.forum, Icons.star, Icons.flag,
  ];
  int selectedIconIndex = 0; // Mặc định chọn icon đầu tiên

  // Danh sách Màu sắc
  final List<Color> categoryColors = [
    Colors.blue.shade200, Colors.red.shade200, Colors.green.shade200,
    Colors.yellow.shade200, Colors.purple.shade200, Colors.orange.shade200, Colors.teal.shade200,
  ];
  int selectedColorIndex = 0; // Mặc định chọn màu đầu tiên

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Trở về màn hình trước
        ),
        title: const Text(
          'New Category',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Nội dung cuộn được
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Chừa không gian cho nút ở dưới
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Input Tên danh mục
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Name',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g., Business English',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Chọn Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: const Text(
                    'Choose an Icon',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: categoryIcons.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIconIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIconIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Icon(
                            categoryIcons[index],
                            color: isSelected ? Colors.white : Colors.grey.shade500,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Chọn Màu Sắc
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: const Text(
                    'Label Color',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: categoryColors.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedColorIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
                          ),
                          child: Center(
                            child: Container(
                              width: isSelected ? 38 : 48,
                              height: isSelected ? 38 : 48,
                              decoration: BoxDecoration(
                                color: categoryColors[index],
                                shape: BoxShape.circle,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Color(0xFF135BEC), size: 24) // Icon check khi được chọn
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Nút Create Category cố định ở dưới
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    backgroundLight,
                    backgroundLight.withValues(alpha: 0.9),
                    backgroundLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý logic tạo danh mục ở đây
                  debugPrint("Created Category with Icon: $selectedIconIndex, Color: $selectedColorIndex");
                  Navigator.pop(context); // Quay về màn hình trước sau khi tạo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: Colors.blue.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Create Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.add_circle, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}