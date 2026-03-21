import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/deck/models/card_model.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';

class FlipMatchGameService {
  static const String scoreHistoryKey = 'flip_match_score_history';
  static const int maxHistoryItems = 20;
  static const String _flipMatchApiPath = '/api/cards/game/flip-match';

  Future<List<FlipWordPair>> fetchWordPairsForGame({
    required int fixedCardCount,
    int fetchBufferCards = 24,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    final response = await api.get(
      _flipMatchApiPath,
      queryParameters: {'limit': fixedCardCount + fetchBufferCards},
    );

    final list = _extractListPayload(response.data);
    final cards = _parseCardList(list);
    return _toUniqueWordPairs(cards);
  }

  Future<List<FlipScoreHistoryEntry>> loadScoreHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(scoreHistoryKey) ?? const [];
    return FlipScoreHistoryEntry.parseFromStorage(raw);
  }

  Future<List<FlipScoreHistoryEntry>> saveScoreHistoryEntry({
    required FlipScoreHistoryEntry entry,
    required List<FlipScoreHistoryEntry> existing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [entry, ...existing].take(maxHistoryItems).toList();

    await prefs.setStringList(
      scoreHistoryKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );

    return updated;
  }

  List<dynamic> _extractListPayload(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map<String, dynamic>) {
      final list =
          responseData['result'] ??
          responseData['data'] ??
          responseData['items'];
      if (list is List) {
        return list;
      }
    }

    throw Exception('Khong the tai du lieu the game.');
  }

  List<CardModel> _parseCardList(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map((item) => CardModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<FlipWordPair> _toUniqueWordPairs(List<CardModel> cards) {
    final uniquePairs = <String, FlipWordPair>{};

    for (final card in cards) {
      final word = card.front.trim();
      final meaning = card.back.trim();
      if (word.isEmpty || meaning.isEmpty) continue;

      final key = '${word.toLowerCase()}|${meaning.toLowerCase()}';
      uniquePairs[key] = FlipWordPair(
        id: card.id,
        word: word,
        meaning: meaning,
      );
    }

    return uniquePairs.values.toList();
  }
}
