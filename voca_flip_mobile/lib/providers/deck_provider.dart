import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deck_model.dart';
import '../services/api_client.dart';
import '../services/deck_service.dart';


const String kBaseUrl = 'http://localhost:8080';

final dioProvider = Provider<Dio>((ref) {
  return ApiClient.create(baseUrl: kBaseUrl);
});

final deckServiceProvider = Provider<DeckService>((ref) {
  return DeckService(ref.read(dioProvider));
});

final deckListProvider = FutureProvider.family<List<DeckModel>, String>((ref, userId) async {
  return ref.read(deckServiceProvider).getDecksByUser(userId);
});
final deckDetailProvider =
    FutureProvider.family<DeckModel, String>((ref, deckId) async {
  return ref.read(deckServiceProvider).getDeckById(deckId);
});
final currentUserIdProvider = Provider<String>((ref) {
  return 'u001';
});

