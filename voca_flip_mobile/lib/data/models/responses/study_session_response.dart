import 'study_card_response.dart';

class StudySessionResponse {
  final String id;
  final int? totalCards;
  final int? rememberedCount;
  final int? forgotCount;
  final int? durationSeconds;
  final String? completedAt;
  final String? createdAt;
  final String? userId;
  final String? deckId;
  final List<StudyCardResponse> cards;

  const StudySessionResponse({
    required this.id,
    this.totalCards,
    this.rememberedCount,
    this.forgotCount,
    this.durationSeconds,
    this.completedAt,
    this.createdAt,
    this.userId,
    this.deckId,
    this.cards = const [],
  });

  /// JSON -> StudySessionResponse
  factory StudySessionResponse.fromJson(Map<String, dynamic> json) {
    return StudySessionResponse(
      id: json['id'] as String,
      totalCards: json['totalCards'] as int?,
      rememberedCount: json['rememberedCount'] as int?,
      forgotCount: json['forgotCount'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      completedAt: json['completedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      userId: json['userId'] as String?,
      deckId: json['deckId'] as String?,
      cards:
          (json['cards'] as List<dynamic>?)
              ?.map(
                (e) => StudyCardResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
