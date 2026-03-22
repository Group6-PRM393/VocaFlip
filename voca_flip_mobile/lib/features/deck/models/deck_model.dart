class DeckModel {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? coverImageUrl;
  final int totalCards;
  final DateTime? createdAt;
  final String userId;

  final double progress; // 0..1
  final int learnedCards;

  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.coverImageUrl,
    required this.totalCards,
    required this.createdAt,
    required this.userId,
    this.progress = 0,
    this.learnedCards = 0,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    final url = json['coverImageUrl']?.toString().trim();
    final created = json['createdAt']?.toString();

    return DeckModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      coverImageUrl: (url == null || url.isEmpty) ? null : url,
      totalCards: toInt(json['totalCards']),
      createdAt: created == null ? null : DateTime.tryParse(created),
      userId: (json['userId'] ?? '').toString(),
      progress: toDouble(json['progress']).clamp(0.0, 1.0),
      learnedCards: toInt(json['learnedCards']),
    );
  }
}
