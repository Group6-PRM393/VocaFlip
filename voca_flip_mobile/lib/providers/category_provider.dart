import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'deck_provider.dart'; 

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(dioProvider));
});

final currentUserIdProvider = Provider<String>((ref) {
  return 'u001';
});


final categoryListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider); // watch
  return ref.watch(categoryServiceProvider).getCategories(userId); // watch cũng được
});


