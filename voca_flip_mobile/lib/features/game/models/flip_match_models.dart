import 'dart:convert';

class FlipWordPair {
  const FlipWordPair({
    required this.id,
    required this.word,
    required this.meaning,
  });

  final String id;
  final String word;
  final String meaning;
}

enum FlipTileSide { word, meaning }

class FlipGameTileModel {
  FlipGameTileModel({
    required this.id,
    required this.pairId,
    required this.text,
    required this.side,
  });

  final String id;
  final String pairId;
  final String text;
  final FlipTileSide side;

  bool isFaceUp = false;
  bool isMatched = false;
}

class FlipScoreHistoryEntry {
  const FlipScoreHistoryEntry({
    required this.score,
    required this.seconds,
    required this.cardCount,
    required this.playedAt,
  });

  final int score;
  final int seconds;
  final int cardCount;
  final DateTime playedAt;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'seconds': seconds,
      'cardCount': cardCount,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory FlipScoreHistoryEntry.fromJson(Map<String, dynamic> json) {
    final playedAtRaw = json['playedAt']?.toString() ?? '';
    return FlipScoreHistoryEntry(
      score: (json['score'] as num?)?.toInt() ?? 0,
      seconds: (json['seconds'] as num?)?.toInt() ?? 0,
      cardCount: (json['cardCount'] as num?)?.toInt() ?? 12,
      playedAt: DateTime.tryParse(playedAtRaw) ?? DateTime.now(),
    );
  }

  static List<FlipScoreHistoryEntry> parseFromStorage(List<String> rawItems) {
    final parsed = <FlipScoreHistoryEntry>[];
    for (final item in rawItems) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          parsed.add(FlipScoreHistoryEntry.fromJson(decoded));
        } else if (decoded is Map) {
          parsed.add(
            FlipScoreHistoryEntry.fromJson(Map<String, dynamic>.from(decoded)),
          );
        }
      } catch (_) {
        // Ignore malformed records so game remains playable.
      }
    }
    return parsed;
  }
}
