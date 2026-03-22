import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/features/category/models/category_model.dart';
import 'package:voca_flip_mobile/features/category/providers/category_provider.dart';
import 'package:voca_flip_mobile/core/utils/category_helper.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final Color primaryColor = const Color(0xFF1337EC);
  final Color backgroundLight = const Color(0xFFFFFFFF);
  final Color surfaceLight = const Color(0xFFF6F6F8);

  late TextEditingController _nameController;
  bool _isLoading = false;

  final List<IconData> categoryIcons = [
    Icons.menu_book,
    Icons.school,
    Icons.work,
    Icons.flight,
    Icons.restaurant,
    Icons.forum,
    Icons.star,
    Icons.flag,
    Icons.flight_takeoff,
    Icons.home,
    Icons.fitness_center,
    Icons.shopping_cart,
    Icons.pets,
  ];
  late int selectedIconIndex;

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
    _nameController = TextEditingController(text: widget.category.categoryName);

    // Tìm index của icon hiện tại, nếu không có thì mặc định là 0
    final currentIcon = CategoryHelper.getIconFromString(
      widget.category.iconCode,
    );
    selectedIconIndex = categoryIcons.indexOf(currentIcon);
    if (selectedIconIndex == -1) selectedIconIndex = 0;

    // Tìm index của color hiện tại, nếu không có thì mặc định là 0
    final currentColorHex = widget.category.colorHex.toUpperCase();
    final foundColorIndex = categoryColors.indexWhere(
      (c) => CategoryHelper.colorToHex(c).toUpperCase() == currentColorHex,
    );
    selectedColorIndex = foundColorIndex != -1 ? foundColorIndex : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CategoryMessages.requiredCategoryName)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = await ref.read(categoryRepositoryProvider.future);

      final iconCode = CategoryHelper.getStringFromIcon(
        categoryIcons[selectedIconIndex],
      );
      final colorHex = CategoryHelper.colorToHex(
        categoryColors[selectedColorIndex],
      );

      await repo.updateCategory(widget.category.id, name, iconCode, colorHex);

      if (!mounted) return;
      // Trả về true báo hiệu đã sửa thành công
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${CategoryMessages.categoryUpdateFailed}: $e')),
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
      backgroundColor: backgroundLight,
      // --- HEADER ---
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Category',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF111218),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: surfaceLight,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            suffixIcon: Icon(
                              Icons.edit,
                              color: primaryColor,
                              size: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // 2. Chọn Icon
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: const Text(
                      'Select Symbol',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111218),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: categoryIcons.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedIconIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedIconIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              categoryIcons[index],
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // 3. Chọn Màu
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: const Text(
                      'Label Color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111218),
                      ),
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
                          onTap: () =>
                              setState(() => selectedColorIndex = index),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: categoryColors[index],
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: categoryColors[index],
                                      width: 2,
                                    )
                                  : null,
                              // Giả lập ring offset của Tailwind
                              boxShadow: isSelected
                                  ? [
                                      const BoxShadow(
                                        color: Colors.white,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: categoryColors[index],
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
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
                    onPressed: _isLoading ? null : _updateCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
