// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:voca_flip_mobile/core/constants/app_colors.dart';

// class DeleteCategoryDialog extends StatelessWidget {
//   final String categoryName;

//   const DeleteCategoryDialog({super.key, required this.categoryName});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.cardBackground,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16), // rounded-2xl
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0), // p-6
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Tự co giãn theo nội dung
//           children: [
//             // --- Icon Warning ---
//             Container(
//               height: 48,
//               width: 48,
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50, // bg-red-50
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.delete,
//                 color: Colors.red, // text-red-600
//                 size: 24,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // --- Tiêu đề & Nội dung ---
//             Text(
//               'Delete Category?',
//               style: GoogleFonts.lexend(
//                 color: AppColors.textPrimary,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Deleting this category will move all associated decks to "Uncategorized".',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.lexend(
//                 color: AppColors.textHint,
//                 fontSize: 15,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 24),

//             // --- Nút bấm (Xếp dọc) ---
            
//             // Nút Delete (Màu Đỏ)
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Đóng Dialog và trả về giá trị 'true' (Xác nhận xóa)
//                   Navigator.of(context).pop(true);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade600,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Delete',
//                   style: GoogleFonts.lexend(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Nút Cancel (Màu Xám)
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: TextButton(
//                 onPressed: () {
//                   // Đóng Dialog và trả về giá trị 'false' (Hủy)
//                   Navigator.of(context).pop(false);
//                 },
//                 style: TextButton.styleFrom(
//                   backgroundColor: const Color(0xFFF0F1F4),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: GoogleFonts.lexend(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// Tên file: lib/delete_category_dialog.dart
import 'package:flutter/material.dart';

class DeleteCategoryDialog extends StatelessWidget {
  final String categoryName;

  const DeleteCategoryDialog({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Để làm viền bo tròn tùy chỉnh
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320), // max-w-[320px]
        padding: const EdgeInsets.all(24), // p-6
        decoration: BoxDecoration(
          color: Colors.white, // dark:bg-[#1C2033] nếu làm dark mode sau này
          borderRadius: BorderRadius.circular(16), // rounded-2xl
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Tự co giãn theo nội dung
          children: [
            // --- Icon Warning ---
            Container(
              width: 48, // h-12 w-12
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50, // bg-red-50
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.delete,
                  color: Colors.red.shade600, // text-red-600
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Tiêu đề & Nội dung ---
            const Text(
              'Delete Category?',
              style: TextStyle(
                color: Color(0xFF111218),
                fontSize: 20, // text-xl
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5, // tracking-tight
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deleting this category will move all associated decks to "Uncategorized".',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF616889),
                fontSize: 15, // text-[15px]
                height: 1.5, // leading-relaxed
              ),
            ),
            const SizedBox(height: 20),

            // --- Nút bấm (Xếp dọc) ---
            
            // Nút Delete (Đỏ)
            SizedBox(
              width: double.infinity,
              height: 48, // h-12
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Đã xóa danh mục: $categoryName");
                  // Đóng Dialog và truyền về kết quả 'true' để báo là đã xóa
                  Navigator.of(context).pop(true); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600, // bg-red-600
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // rounded-xl
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12), // gap-3

            // Nút Cancel (Xám)
            SizedBox(
              width: double.infinity,
              height: 48, // h-12
              child: TextButton(
                onPressed: () {
                  // Đóng Dialog và truyền về kết quả 'false'
                  Navigator.of(context).pop(false);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F1F4), // bg-[#f0f1f4]
                  foregroundColor: const Color(0xFF111218), // text-[#111218]
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // rounded-xl
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}