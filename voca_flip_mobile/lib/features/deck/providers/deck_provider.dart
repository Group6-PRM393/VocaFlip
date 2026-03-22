import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/config/app_config.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/deck/repositories/deck_repository.dart';
import 'package:voca_flip_mobile/features/deck/models/deck_model.dart';

/// Provider trung tâm cho ApiService (có JWT Interceptor).
/// Tất cả các Repository đều dùng chung provider này.
final apiServiceProvider = FutureProvider<ApiService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ApiService(prefs);
});

/// Provider cho DeckRepository
final deckRepositoryProvider = FutureProvider<DeckRepository>((ref) async {
  final apiService = await ref.watch(apiServiceProvider.future);
  return DeckRepository(apiService);
});

/// Lấy danh sách Deck của user hiện tại (backend tự xác định qua JWT)
final deckListProvider = FutureProvider<List<DeckModel>>((ref) async {
  final repo = await ref.watch(deckRepositoryProvider.future);
  return repo.getMyDecks();
});

/// Lấy chi tiết Deck theo deckId
final deckDetailProvider = FutureProvider.family<DeckModel, String>((
  ref,
  deckId,
) async {
  final repo = await ref.watch(deckRepositoryProvider.future);
  return repo.getDeckById(deckId);
});

/// Lấy userId từ SharedPreferences (đã lưu khi login)
final currentUserIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(AppConfig.userIdKey);
  if (userId == null || userId.isEmpty) {
    throw Exception('User is not logged in or userId is missing.');
  }
  return userId;
});
