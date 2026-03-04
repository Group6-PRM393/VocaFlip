import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/models/card_model.dart';
import 'package:voca_flip_mobile/services/card_service.dart';
import 'deck_provider.dart'; 

final cardServiceProvider = Provider<CardService>((ref) {
  return CardService(ref.read(dioProvider));
});

final cardListProvider =
    FutureProvider.family<List<CardModel>, String>((ref, deckId) async {
  return ref.read(cardServiceProvider).getCardsByDeck(deckId);
});
