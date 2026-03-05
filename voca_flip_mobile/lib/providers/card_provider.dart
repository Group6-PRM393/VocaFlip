import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/card_repository.dart';
import '../models/card_model.dart';
import 'deck_provider.dart';

/// Provider cho CardRepository
final cardRepositoryProvider = FutureProvider<CardRepository>((ref) async {
  final apiService = await ref.watch(apiServiceProvider.future);
  return CardRepository(apiService);
});

/// Lấy danh sách Card theo deckId
final cardListProvider = FutureProvider.family<List<CardModel>, String>((
  ref,
  deckId,
) async {
  final repo = await ref.watch(cardRepositoryProvider.future);
  return repo.getCardsByDeck(deckId);
});
