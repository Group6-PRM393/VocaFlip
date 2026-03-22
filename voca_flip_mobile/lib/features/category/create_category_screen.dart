import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/features/category/providers/category_provider.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';
import 'package:voca_flip_mobile/core/utils/category_helper.dart';

class CreateCategoryScreen extends ConsumerStatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  ConsumerState<CreateCategoryScreen> createState() =>
      _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends ConsumerState<CreateCategoryScreen> {
  final Color primaryColor = const Color(0xFF135BEC);
  final Color backgroundLight = const Color(0xFFF6F6F8);

  // Danh sách Icons
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
  ];
  int selectedIconIndex = 0; // Mặc định chọn icon đầu tiên

  // Danh sách Màu sắc
  final List<Color> categoryColors = [
    const Color(0xFF135BEC), // Blue (Primary)
    const Color(0xFFEF4444), // Red
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFFEF08A), // Yellow
    const Color(0xFF10B981), // Emerald
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink
  ];
  int selectedColorIndex = 0; // Mặc định chọn màu đầu tiên

  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CategoryMessages.requiredCategoryName)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await ref.read(currentUserIdProvider.future);
      final repo = await ref.read(categoryRepositoryProvider.future);

      final iconCode = CategoryHelper.getStringFromIcon(
        categoryIcons[selectedIconIndex],
      );
      final colorHex = CategoryHelper.colorToHex(
        categoryColors[selectedColorIndex],
      );

      await repo.createCategory(userId, name, iconCode, colorHex);

      if (!mounted) return;
      // Trả về true báo hiệu đã tạo thành công
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${CategoryMessages.categoryCreateFailed}: $e')),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Nội dung cuộn được
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ), // Chừa không gian cho nút ở dưới
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Business English',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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

                // 2. Chọn Icon
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: const Text(
                    'Choose an Icon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        onTap: () => setState(() => selectedIconIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(
                                        alpha: 0.4,
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
                                : Colors.grey.shade500,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: const Text(
                    'Label Color',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
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
                            border: isSelected
                                ? Border.all(color: primaryColor, width: 2)
                                : null,
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
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    ) // Icon check khi được chọn
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
                onPressed: _isLoading ? null : _createCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Create Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
