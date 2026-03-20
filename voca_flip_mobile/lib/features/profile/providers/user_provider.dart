import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/auth/models/auth_model.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart'; // Sử dụng chung apiServiceProvider
import 'package:voca_flip_mobile/features/profile/repositories/user_repository.dart';

/// Cung cấp đối tượng UserRepository
final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  final apiService = await ref.watch(apiServiceProvider.future);
  return UserRepository(apiService);
});

/// Lấy thông tin User hiện tại (từ endpoint /api/user/me)
final currentUserProfileProvider = FutureProvider<UserModel>((ref) async {
  final repo = await ref.watch(userRepositoryProvider.future);
  return repo.getCurrentUser();
});
