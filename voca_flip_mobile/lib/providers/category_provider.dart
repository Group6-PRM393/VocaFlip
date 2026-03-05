import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/category_repository.dart';
import '../models/category_model.dart';
import 'deck_provider.dart';

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
