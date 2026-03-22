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

class FlipGameDeck {
  const FlipGameDeck({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.totalCards,
  });

  final String id;
  final String title;
  final String? coverImageUrl;
  final int totalCards;

  factory FlipGameDeck.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final image = json['coverImageUrl']?.toString().trim();
    return FlipGameDeck(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      coverImageUrl: (image == null || image.isEmpty) ? null : image,
      totalCards: toInt(json['totalCards']),
    );
  }
}

class FlipGameSummary {
  const FlipGameSummary({
    required this.totalScore,
    required this.totalGames,
    required this.bestScore,
    required this.top3Scores,
  });

  final int totalScore;
  final int totalGames;
  final int bestScore;
  final List<int> top3Scores;

  factory FlipGameSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return FlipGameSummary(
      totalScore: toInt(json['totalScore']),
      totalGames: toInt(json['totalGames']),
      bestScore: toInt(json['bestScore']),
      top3Scores: (json['top3Scores'] is List)
          ? (json['top3Scores'] as List)
                .map((item) => toInt(item))
                .take(3)
                .toList()
          : const [],
    );
  }

  static const empty = FlipGameSummary(
    totalScore: 0,
    totalGames: 0,
    bestScore: 0,
    top3Scores: [],
  );
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
    required this.moves,
    required this.playedAt,
  });

  final int score;
  final int seconds;
  final int cardCount;
  final int moves;
  final DateTime playedAt;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'seconds': seconds,
      'cardCount': cardCount,
      'moves': moves,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory FlipScoreHistoryEntry.fromJson(Map<String, dynamic> json) {
    final playedAtRaw = json['playedAt']?.toString() ?? '';
    return FlipScoreHistoryEntry(
      score: (json['score'] as num?)?.toInt() ?? 0,
      seconds: (json['seconds'] as num?)?.toInt() ?? 0,
      cardCount: (json['cardCount'] as num?)?.toInt() ?? 12,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
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
