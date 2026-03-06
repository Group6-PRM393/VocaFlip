// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:voca_flip_mobile/core/constants/app_colors.dart';
// import 'package:voca_flip_mobile/features/category/models/category_model.dart';
// import 'package:voca_flip_mobile/core/utils/category_helper.dart';

// class EditCategoryScreen extends StatefulWidget {
//   // Biến này dùng để nhận dữ liệu của danh mục cần sửa từ màn hình trước truyền sang
//   final CategoryModel category; 

//   const EditCategoryScreen({super.key, required this.category});

//   @override
//   State<EditCategoryScreen> createState() => _EditCategoryScreenState();
// }

// class _EditCategoryScreenState extends State<EditCategoryScreen> {
//   late TextEditingController _nameController;

//   // Danh sách Icon Code (Giống y hệt file HTML Edit)
//   final List<String> iconCodes = [
//     'flight_takeoff', 'work', 'school', 'restaurant',
//     'home', 'fitness_center', 'shopping_cart', 'pets'
//   ];
//   late int selectedIconIndex;

//   // Danh sách Color Hex (Giống y hệt file HTML Edit)
//   final List<String> colorHexes = [
//     '#1337ec', '#ef4444', '#f59e0b', '#10b981', '#8b5cf6', '#ec4899'
//   ];
//   late int selectedColorIndex;

//   @override
//   void initState() {
//     super.initState();
//     // 1. Điền sẵn tên cũ vào ô Text
//     _nameController = TextEditingController(text: widget.category.categoryName);

//     // 2. Tìm vị trí của Icon cũ để bôi đậm, nếu không thấy thì mặc định chọn cái số 0
//     selectedIconIndex = iconCodes.indexOf(widget.category.iconCode);
//     if (selectedIconIndex == -1) selectedIconIndex = 0; 

//     // 3. Tìm vị trí của Màu cũ để bôi đậm
//     selectedColorIndex = colorHexes.indexWhere(
//         (c) => c.toLowerCase() == widget.category.colorHex.toLowerCase());
//     if (selectedColorIndex == -1) selectedColorIndex = 0;
//   }

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
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
//           onPressed: () => Navigator.pop(context), // Nút Back
//         ),
//         title: Text(
//           'Edit Category',
//           style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),

//       // --- BODY ---
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 100), // Chừa chỗ cho nút Save
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 1. Tên Category
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'CATEGORY NAME',
//                         style: GoogleFonts.lexend(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: _nameController,
//                         style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textPrimary),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: AppColors.cardBackground,
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                           suffixIcon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: AppColors.divider),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 16, endIndent: 16),

//                 // 2. Chọn Icon
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//                   child: Text(
//                     'Select Symbol',
//                     style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
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
//                             border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
//                             boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
//                           ),
//                           child: Icon(iconData, color: isSelected ? Colors.white : AppColors.textHint, size: 32),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 24),
//                 const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 16, endIndent: 16),

//                 // 3. Chọn Màu Sắc
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//                   child: Text('Label Color', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Wrap(
//                     spacing: 16, runSpacing: 16,
//                     children: List.generate(colorHexes.length, (index) {
//                       final isSelected = index == selectedColorIndex;
//                       final colorValue = CategoryHelper.hexToColor(colorHexes[index]);
                      
//                       return GestureDetector(
//                         onTap: () => setState(() => selectedColorIndex = index),
//                         child: Container(
//                           width: 48, height: 48,
//                           decoration: BoxDecoration(
//                             color: colorValue,
//                             shape: BoxShape.circle,
//                             border: isSelected ? Border.all(color: colorValue, width: 2) : null,
//                             boxShadow: isSelected ? [
//                               const BoxShadow(color: Colors.white, spreadRadius: 2),
//                               BoxShadow(color: colorValue, spreadRadius: 4),
//                             ] : [],
//                           ),
//                           child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),

//           // --- FIXED BOTTOM BUTTON (SAVE) ---
//           Positioned(
//             bottom: 0, left: 0, right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.cardBackground.withValues(alpha: 0.95),
//                 border: const Border(top: BorderSide(color: AppColors.divider)),
//               ),
//               child: SizedBox(
//                 width: double.infinity, height: 52,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_nameController.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Vui lòng nhập tên danh mục'))
//                       );
//                       return;
//                     }

//                     // ĐÓNG GÓI DỮ LIỆU ĐỂ TRẢ VỀ
//                     // LƯU Ý QUAN TRỌNG: Phải giữ nguyên ID cũ để Backend biết đang update dòng nào
//                     final updatedCategory = CategoryModel(
//                       id: widget.category.id, 
//                       categoryName: _nameController.text.trim(),
//                       iconCode: iconCodes[selectedIconIndex],
//                       colorHex: colorHexes[selectedColorIndex],
//                       deckCount: widget.category.deckCount, // Giữ nguyên số lượng bộ bài
//                     );
                    
//                     // Trả cục dữ liệu này về cho màn hình Quản lý
//                     Navigator.pop(context, updatedCategory);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Text('Save Changes', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// Tên file: lib/edit_category_screen.dart
import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/features/category/category_management_screen.dart'; // Import để lấy model CategoryItem

class EditCategoryScreen extends StatefulWidget {
  final CategoryItem category; // Nhận dữ liệu category được truyền từ màn hình trước

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final Color primaryColor = const Color(0xFF1337EC);
  final Color backgroundLight = const Color(0xFFFFFFFF);
  final Color surfaceLight = const Color(0xFFF6F6F8);
  
  late TextEditingController _nameController;

  // Danh sách Icons giống HTML
  final List<IconData> categoryIcons = [
    Icons.flight_takeoff, Icons.work, Icons.school, Icons.restaurant,
    Icons.home, Icons.fitness_center, Icons.shopping_cart, Icons.pets,
  ];
  late int selectedIconIndex;

  // Danh sách Màu sắc giống HTML
  final List<Color> categoryColors = [
    const Color(0xFF1337EC), // Blue (Primary)
    const Color(0xFFEF4444), // Red
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF10B981), // Emerald
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink
  ];
  int selectedColorIndex = 0; // Mặc định chọn màu đầu tiên

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu dựa trên category được truyền vào
    _nameController = TextEditingController(text: widget.category.title);
    
    // Tìm index của icon hiện tại, nếu không có thì mặc định là 0
    selectedIconIndex = categoryIcons.indexOf(widget.category.icon);
    if (selectedIconIndex == -1) selectedIconIndex = 0; 
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      // --- HEADER ---
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Category',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      
      body: Column(
        children: [
          // --- MAIN CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tên Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CATEGORY NAME',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF111218)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: surfaceLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            suffixIcon: Icon(Icons.edit, color: primaryColor, size: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),

                  // 2. Chọn Icon
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: const Text(
                      'Select Symbol',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111218)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              color: isSelected ? primaryColor : surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                  : [],
                            ),
                            child: Icon(
                              categoryIcons[index],
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),

                  // 3. Chọn Màu
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: const Text(
                      'Label Color',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111218)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(categoryColors.length, (index) {
                        final isSelected = index == selectedColorIndex;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColorIndex = index),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: categoryColors[index],
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: categoryColors[index], width: 2) : null,
                              // Giả lập ring offset của Tailwind
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(color: Colors.white, spreadRadius: 2),
                                      BoxShadow(color: categoryColors[index], spreadRadius: 4),
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32), // Padding cho đoạn cuộn cuối cùng
                ],
              ),
            ),
          ),

          // --- BOTTOM ACTIONS ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundLight.withValues(alpha: 0.95),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Vừa đủ nội dung
              children: [
                // Nút Save Changes
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint("Saved: ${_nameController.text}");
                      Navigator.pop(context); // Quay về
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Nút Delete Category
                // SizedBox(
                //   width: double.infinity,
                //   height: 48,
                //   child: TextButton(
                //     onPressed: () {
                //       debugPrint("Xóa category: ${widget.category.title}");
                //       // Logic xóa có thể gọi popup Confirm ở đây
                //     },
                //     style: TextButton.styleFrom(
                //       foregroundColor: Colors.red, // Màu text và hiệu ứng nhấn
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //     ),
                //     child: const Text(
                //       'Delete Category',
                //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}