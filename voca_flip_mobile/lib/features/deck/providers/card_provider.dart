import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/deck/repositories/card_repository.dart';
import 'package:voca_flip_mobile/features/deck/models/card_model.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';

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
