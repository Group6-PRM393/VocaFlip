import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/features/category/create_category_screen.dart';
import 'package:voca_flip_mobile/features/category/edit_category_screen.dart';
import 'package:voca_flip_mobile/features/category/delete_category_dialog.dart';
import 'package:voca_flip_mobile/features/category/models/category_model.dart';
import 'package:voca_flip_mobile/features/category/providers/category_provider.dart';
import 'package:voca_flip_mobile/core/utils/category_helper.dart';
import 'package:voca_flip_mobile/features/deck/screens/deck_list_screen.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  // --- Định nghĩa màu sắc ---
  final Color primaryColor = const Color(0xFF135BEC);
  final Color backgroundLight = const Color(0xFFF6F6F8);
  final Color surfaceLight = const Color(0xFFFFFFFF);
  final Color textSlate900 = const Color(0xFF0F172A);
  final Color textSlate500 = const Color(0xFF64748B);
  final Color textSlate300 = const Color(0xFFCBD5E1);

  // ===========================================================================
  // HÀM ĐIỀU HƯỚNG
  // ===========================================================================

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCategoryScreen()),
    );
    if (result == true) {
      ref.invalidate(categoryListProvider);
      try {
        await ref.read(categoryListProvider.future);
      } catch (_) {}
    }
  }

  void _navigateToEdit(CategoryModel category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(category: category),
      ),
    );
    if (result == true) {
      ref.invalidate(categoryListProvider);
      try {
        await ref.read(categoryListProvider.future);
      } catch (_) {}
    }
  }

  void _navigateToCategoryDecks(CategoryModel category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckListScreen(
          filterCategoryId: category.id,
          filterCategoryName: category.categoryName,
        ),
      ),
    );
    // Always refetch when returning from DeckListScreen to update deck count
    ref.invalidate(categoryListProvider);
    try {
      await ref.read(categoryListProvider.future);
    } catch (_) {}
  }

  void _confirmDelete(CategoryModel category) async {
    // Hiển thị Dialog
    final bool? isDeleted = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF111218).withValues(alpha: 0.6),
      builder: (BuildContext context) {
        return DeleteCategoryDialog(
          categoryName: category.categoryName,
          deckCount: category.deckCount,
        );
      },
    );

    if (isDeleted == true) {
      try {
        final repo = await ref.read(categoryRepositoryProvider.future);
        await repo.deleteCategory(category.id);

        ref.invalidate(categoryListProvider);
        try {
          await ref.read(categoryListProvider.future);
        } catch (_) {}

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CategoryMessages.deletedCategory(category.categoryName),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'My Decks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: categoriesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(categoryListProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet. Create one.'));
          }
          return ListView.separated(
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
          );
        },
      ),
      floatingActionButton: _buildCategoryFab(),
    );
  }

  Widget _buildCategoryFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: 'category_fab',
        onPressed: _navigateToAdd,
        backgroundColor: primaryColor,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel item) {
    return Material(
      color: surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _navigateToCategoryDecks(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                    color: CategoryHelper.hexToColor(
                      item.colorHex,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CategoryHelper.getIconFromString(item.iconCode),

                    color: CategoryHelper.hexToColor(item.colorHex),

                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.categoryName,
                        style: TextStyle(
                          color: textSlate900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.deckCount} Decks',
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
        ),
      ),
    );
  }
}
