import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/card/models/card_model.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';

class FlipMatchGameService {
  static const String scoreHistoryKey = 'flip_match_score_history';
  static const String scoreSummaryKey = 'flip_match_score_summary';
  static const int maxHistoryItems = 20;
  static const String _flipMatchDecksApiPath =
      '/api/cards/game/flip-match/decks';
  static const String _flipMatchHistoryApiPath =
      '/api/cards/game/flip-match/history';
  static const String _flipMatchSummaryApiPath =
      '/api/cards/game/flip-match/summary';

  Future<List<FlipGameDeck>> fetchEligibleDecks({int minCards = 12}) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    final response = await api.get(
      _flipMatchDecksApiPath,
      queryParameters: {'minCards': minCards},
    );

    final list = _extractListPayload(response.data);
    return list
        .whereType<Map>()
        .map((item) => FlipGameDeck.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FlipWordPair>> fetchWordPairsForDeck({
    required String deckId,
    required int fixedCardCount,
    int fetchBufferCards = 24,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    final response = await api.get(
      '$_flipMatchDecksApiPath/$deckId',
      queryParameters: {'limit': fixedCardCount + fetchBufferCards},
    );

    final list = _extractListPayload(response.data);
    final cards = _parseCardList(list);
    final cardsFromSelectedDeck = cards
        .where((card) => card.deckId.trim() == deckId.trim())
        .toList();

    if (cardsFromSelectedDeck.length != cards.length) {
      throw Exception(
        'Invalid game data: cards from a different deck were returned.',
      );
    }

    return _toUniqueWordPairs(cardsFromSelectedDeck);
  }

  Future<List<FlipScoreHistoryEntry>> loadScoreHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    try {
      final response = await api.get(
        _flipMatchHistoryApiPath,
        queryParameters: {'limit': maxHistoryItems},
      );

      final list = _extractListPayload(response.data);
      final parsed = list
          .whereType<Map>()
          .map(
            (item) =>
                FlipScoreHistoryEntry.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      // If server responds with empty history while local cache already has data,
      // keep local history so Top scores are not visually reset to "--".
      if (parsed.isEmpty) {
        final localParsed = _loadLocalScoreHistory(prefs);
        if (localParsed.isNotEmpty) {
          return localParsed;
        }
      }

      await _saveHistoryToLocalCache(parsed);
      return parsed;
    } catch (_) {
      return _loadLocalScoreHistory(prefs);
    }
  }

  Future<FlipGameSummary> loadScoreSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    try {
      final response = await api.get(_flipMatchSummaryApiPath);
      final result = _extractObjectPayload(response.data);
      final summary = FlipGameSummary.fromJson(result);
      await prefs.setString(scoreSummaryKey, jsonEncode(result));
      return summary;
    } catch (_) {
      final raw = prefs.getString(scoreSummaryKey);
      if (raw == null || raw.isEmpty) return FlipGameSummary.empty;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return FlipGameSummary.fromJson(decoded);
        }
      } catch (_) {
        // Ignore malformed cache.
      }
      return FlipGameSummary.empty;
    }
  }

  Future<FlipGameSummary> saveScoreHistoryEntry({
    required FlipScoreHistoryEntry entry,
    required String? deckId,
    required List<FlipScoreHistoryEntry> existing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    try {
      final response = await api.post(
        _flipMatchHistoryApiPath,
        data: {
          'deckId': deckId,
          'score': entry.score,
          'seconds': entry.seconds,
          'cardCount': entry.cardCount,
          'moves': entry.moves,
          'playedAt': entry.playedAt.toIso8601String(),
        },
      );

      final result = _extractObjectPayload(response.data);
      final summary = FlipGameSummary.fromJson(result);
      await prefs.setString(scoreSummaryKey, jsonEncode(result));

      // Refresh history cache from server after successful save.
      final latestHistory = await loadScoreHistory();
      if (latestHistory.isNotEmpty) {
        await _saveHistoryToLocalCache(latestHistory);
      } else {
        final fallbackLocal = _prependUniqueEntry(entry, existing);
        await _saveHistoryToLocalCache(fallbackLocal);
      }

      return summary;
    } catch (_) {
      // Fallback to local cache if BE is unavailable.
      final updated = _prependUniqueEntry(entry, existing);
      await _saveHistoryToLocalCache(updated);

      final currentSummary = await loadScoreSummary();
      final fallbackSummary = FlipGameSummary(
        totalScore: currentSummary.totalScore + entry.score,
        totalGames: currentSummary.totalGames + 1,
        bestScore: entry.score > currentSummary.bestScore
            ? entry.score
            : currentSummary.bestScore,
        top3Scores: ([
          ...currentSummary.top3Scores,
          entry.score,
        ]..sort((a, b) => b.compareTo(a))).take(3).toList(),
      );
      await prefs.setString(
        scoreSummaryKey,
        jsonEncode({
          'totalScore': fallbackSummary.totalScore,
          'totalGames': fallbackSummary.totalGames,
          'bestScore': fallbackSummary.bestScore,
          'top3Scores': fallbackSummary.top3Scores,
        }),
      );
      return fallbackSummary;
    }
  }

  List<FlipScoreHistoryEntry> _loadLocalScoreHistory(SharedPreferences prefs) {
    final raw = prefs.getStringList(scoreHistoryKey) ?? const [];
    return FlipScoreHistoryEntry.parseFromStorage(raw);
  }

  List<FlipScoreHistoryEntry> _prependUniqueEntry(
    FlipScoreHistoryEntry entry,
    List<FlipScoreHistoryEntry> existing,
  ) {
    final isSameEntry = (FlipScoreHistoryEntry item) =>
        item.playedAt == entry.playedAt &&
        item.score == entry.score &&
        item.seconds == entry.seconds &&
        item.cardCount == entry.cardCount &&
        item.moves == entry.moves;

    final filtered = existing.where((item) => !isSameEntry(item));
    return [entry, ...filtered].take(maxHistoryItems).toList();
  }

  Future<void> _saveHistoryToLocalCache(
    List<FlipScoreHistoryEntry> updated,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      scoreHistoryKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
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

    throw Exception('Unable to load game card data.');
  }

  Map<String, dynamic> _extractObjectPayload(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final obj = responseData['result'] ?? responseData['data'];
      if (obj is Map<String, dynamic>) {
        return obj;
      }
      if (obj is Map) {
        return Map<String, dynamic>.from(obj);
      }

      return responseData;
    }

    throw Exception('Unable to parse object payload from response.');
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
