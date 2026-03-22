import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/category/repositories/category_repository.dart';
import 'package:voca_flip_mobile/features/category/models/category_model.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';

/// Provider cho CategoryRepository
final categoryRepositoryProvider = FutureProvider<CategoryRepository>((
  ref,
) async {
  final apiService = await ref.watch(apiServiceProvider.future);
  return CategoryRepository(apiService);
});

/// Lấy danh sách Category
final categoryListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final repo = await ref.watch(categoryRepositoryProvider.future);
  return repo.getCategories(userId);
});
