// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:voca_flip_mobile/core/constants/app_colors.dart';
// import 'package:voca_flip_mobile/features/category/models/category_model.dart';
// import 'package:voca_flip_mobile/features/category/repositories/category_repository.dart';
// import 'package:voca_flip_mobile/core/services/api_service.dart';
// import 'package:voca_flip_mobile/core/utils/category_helper.dart';
// import 'package:voca_flip_mobile/features/category/create_category_screen.dart';
// import 'package:voca_flip_mobile/features/category/edit_category_screen.dart';
// import 'package:voca_flip_mobile/features/category/delete_category_dialog.dart';

// class CategoryManagementScreen extends StatefulWidget {
//   const CategoryManagementScreen({super.key});

//   @override
//   State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
// }

// class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
//   late CategoryRepository _categoryRepo;

//   List<CategoryModel> categories = [];
//   bool isLoading = true; // Trạng thái đang tải data
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _initRepositoryAndFetchData();
//   }

//   Future<void> _initRepositoryAndFetchData() async {
//     // Khởi tạo ApiService và Repository
//     final prefs = await SharedPreferences.getInstance();
//     final apiService = ApiService(prefs);
//     _categoryRepo = CategoryRepository(apiService);

//     await _loadCategories();
//   }

//   Future<void> _loadCategories() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });

//     try {
//       // Gọi API lấy danh sách. Tạm thời fix cứng userId, sau này lấy từ AuthProvider
//       final result = await _categoryRepo.getCategories("67c33ee4924a2e1d743a6d71"); // Sửa thành userId thực tế của bạn
//       setState(() {
//         categories = result;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Lỗi kết nối mạng: $e';
//       });
//     }
//   }

//   Future<void> _navigateToAdd() async {
//     // 1. Chờ dữ liệu trả về từ màn Create
//     final CategoryModel? newData = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateCategoryScreen()),
//     );

//     // 2. Nếu người dùng bấm Create (newData không null)
//     if (newData != null) {
//       // Bật hiệu ứng loading
//       setState(() => isLoading = true);

//       try {
//         // GỌI API THÊM MỚI VÀO DATABASE
//         final createdCategory = await _categoryRepo.createCategory("67c33ee4924a2e1d743a6d71", newData);

//         // Cập nhật giao diện
//         setState(() {
//           categories.add(createdCategory);
//           isLoading = false;
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Thêm danh mục thành công!'), backgroundColor: Colors.green),
//           );
//         }
//       } catch (e) {
//         setState(() => isLoading = false);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _navigateToEdit(CategoryModel category) async {
//     // 1. Mở màn hình Sửa và truyền dữ liệu cũ sang
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditCategoryScreen(category: category),
//       ),
//     );

//     // 2. Xử lý khi người dùng bấm Save và trả dữ liệu về
//     if (result != null && result is CategoryModel) {

//       // Bật hiệu ứng loading xoay xoay
//       setState(() => isLoading = true);

//       try {
//         // 3. Gọi API Update lên Spring Boot
//         final updatedCategory = await _categoryRepo.updateCategory(result.id, result);

//         // 4. Nếu thành công, tìm vị trí category cũ trong danh sách và ghi đè cái mới vào
//         setState(() {
//           final index = categories.indexWhere((c) => c.id == result.id);
//           if (index != -1) {
//             categories[index] = updatedCategory;
//           }
//           isLoading = false; // Tắt loading
//         });

//         // Hiện thông báo màu xanh lá
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cập nhật danh mục thành công!'), backgroundColor: Colors.green),
//           );
//         }
//       } catch (e) {
//         // Nếu lỗi, tắt loading và hiện thông báo màu đỏ
//         setState(() => isLoading = false);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _confirmDelete(CategoryModel category) async {
//     // 1. Hiển thị Dialog và chờ kết quả người dùng chọn (true = Xóa, false = Hủy)
//     final bool? isConfirmed = await showDialog<bool>(
//       context: context,
//       barrierColor: const Color(0xFF111218).withValues(alpha: 0.6), // Làm tối nền mờ giống HTML
//       builder: (BuildContext context) {
//         return DeleteCategoryDialog(categoryName: category.categoryName);
//       },
//     );

//     // 2. Nếu người dùng bấm nút "Delete" màu đỏ (trả về true)
//     if (isConfirmed == true) {

//       // Bật hiệu ứng loading xoay xoay
//       setState(() => isLoading = true);

//       try {
//         // 3. Gọi API Delete lên Spring Boot
//         await _categoryRepo.deleteCategory(category.id);

//         // 4. Cập nhật lại danh sách trên màn hình (xóa phần tử đó đi)
//         setState(() {
//           categories.removeWhere((item) => item.id == category.id);
//           isLoading = false;
//         });

//         // Hiện thông báo thành công
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Đã xóa danh mục thành công!'), backgroundColor: Colors.green),
//           );
//         }
//       } catch (e) {
//         // Bắt lỗi nếu gọi API thất bại
//         setState(() => isLoading = false);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 2,
//         centerTitle: true,
//         automaticallyImplyLeading: false, // Bỏ nút back vì nó nằm trong Tab
//         title: Text(
//           'Categories',
//           style: GoogleFonts.lexend(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),

//       // Kiểm tra trạng thái để hiển thị Loading, Lỗi, hoặc Danh sách
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
//               : categories.isEmpty
//                   ? Center(
//                       child: Text('Chưa có danh mục nào.', style: GoogleFonts.lexend(color: AppColors.textHint)),
//                     )
//                   : ListView.separated(
//                       padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
//                       itemCount: categories.length,
//                       separatorBuilder: (context, index) => const SizedBox(height: 12),
//                       itemBuilder: (context, index) {
//                         return _buildCategoryCard(categories[index]);
//                       },
//                     ),

//       // Nút Thêm mới
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAdd,
//         backgroundColor: AppColors.primary,
//         shape: const CircleBorder(),
//         child: const Icon(Icons.add, size: 28, color: Colors.white),
//       ),
//     );
//   }

//   // Thẻ Category
//   Widget _buildCategoryCard(CategoryModel item) {
//     final itemColor = CategoryHelper.hexToColor(item.colorHex);
//     final itemIcon = CategoryHelper.getIconFromString(item.iconCode);

//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.divider),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
//         child: Row(
//           children: [
//             Container(
//               width: 48, height: 48,
//               decoration: BoxDecoration(
//                 color: itemColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(itemIcon, color: itemColor, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.categoryName,
//                     style: GoogleFonts.lexend(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     '${item.deckCount} Decks',
//                     style: GoogleFonts.lexend(color: AppColors.textHint, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 InkWell(
//                   onTap: () => _navigateToEdit(item),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     child: Text('Edit', style: GoogleFonts.lexend(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => _confirmDelete(item),
//                   icon: const Icon(Icons.delete, size: 22, color: AppColors.textHint),
//                   constraints: const BoxConstraints(),
//                   padding: EdgeInsets.zero,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Tên file: lib/category_management_screen.dart
import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/features/category/create_category_screen.dart'; // Import màn hình thêm mới
import 'package:voca_flip_mobile/features/category/edit_category_screen.dart'; // Import màn hình sửa
import 'package:voca_flip_mobile/features/category/delete_category_dialog.dart';

// --- Model Dữ liệu ---
class CategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  CategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  // --- Định nghĩa màu sắc ---
  final Color primaryColor = const Color(
    0xFF135BEC,
  ); // Cập nhật màu khớp HTML mới
  final Color backgroundLight = const Color(0xFFF6F6F8);
  final Color surfaceLight = const Color(0xFFFFFFFF);
  final Color textSlate900 = const Color(0xFF0F172A);
  final Color textSlate500 = const Color(0xFF64748B);
  final Color textSlate300 = const Color(0xFFCBD5E1);

  // --- Dữ liệu giả lập ---
  final List<CategoryItem> categories = [
    CategoryItem(
      id: '1',
      title: 'Business',
      subtitle: '12 Decks',
      icon: Icons.business_center,
    ),
    CategoryItem(
      id: '2',
      title: 'Travel',
      subtitle: '5 Decks',
      icon: Icons.flight,
    ),
    CategoryItem(
      id: '3',
      title: 'Academic',
      subtitle: '8 Decks',
      icon: Icons.school,
    ),
    CategoryItem(
      id: '4',
      title: 'Daily Life',
      subtitle: '20 Decks',
      icon: Icons.local_cafe,
    ),
    CategoryItem(
      id: '5',
      title: 'Hobbies',
      subtitle: '3 Decks',
      icon: Icons.palette,
    ),
  ];

  // ===========================================================================
  // HÀM ĐIỀU HƯỚNG
  // ===========================================================================

  void _navigateToAdd() {
    // CHUYỂN SANG MÀN HÌNH TẠO MỚI
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCategoryScreen()),
    );
  }

  void _navigateToEdit(CategoryItem category) {
    // Chuyển sang màn hình SỬA và truyền dữ liệu của category được bấm vào
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(category: category),
      ),
    );
  }

  void _confirmDelete(CategoryItem category) async {
    // Hiển thị Dialog
    final bool? isDeleted = await showDialog<bool>(
      context: context,
      barrierColor: const Color(
        0xFF111218,
      ).withValues(alpha: 0.6), // bg-[#111218]/60 làm tối màu nền
      builder: (BuildContext context) {
        return DeleteCategoryDialog(categoryName: category.title);
      },
    );

    // Xử lý sau khi Dialog đóng lại
    if (isDeleted == true) {
      // Nếu người dùng chọn Delete -> Cập nhật lại danh sách (giả lập)
      setState(() {
        categories.removeWhere((item) => item.id == category.id);
      });

      if (!mounted) return;

      // Hiện thông báo nhỏ (Snackbar) ở dưới đáy màn hình
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xóa ${category.title}')));
    }
  }

  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 96,
        ),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _buildCategoryCard(item);
        },
      ),
      // ĐÃ THAY ĐỔI: Gọi hàm _buildCategoryFab thay vì viết code trực tiếp tại đây
      floatingActionButton: _buildCategoryFab(),
    );
  }

  // ĐÃ THÊM MỚI: Tách hàm FAB ra riêng và thêm heroTag
  Widget _buildCategoryFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: 'category_fab', // Thêm heroTag để tránh lỗi đụng độ animation
        onPressed: _navigateToAdd, // Gọi hàm chuyển màn hình
        backgroundColor: primaryColor,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: textSlate900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(color: textSlate500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _navigateToEdit(item),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(item),
                  icon: Icon(Icons.delete, size: 22, color: textSlate300),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
