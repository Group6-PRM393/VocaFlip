import 'package:flutter/material.dart';

class DeleteCategoryDialog extends StatelessWidget {
  final String categoryName;
  final int deckCount;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryName,
    required this.deckCount,
  });

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
              deckCount > 0
                  ? 'Category "$categoryName" currently has $deckCount deck(s). Deleting this category will also delete all those decks.'
                  : 'Are you sure you want to delete category "$categoryName"?',
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
                  debugPrint(
                    "$categoryName is deleted",
                  ); // Thêm log để kiểm tra
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
