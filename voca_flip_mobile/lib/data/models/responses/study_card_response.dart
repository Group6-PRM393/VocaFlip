class StudyCardResponse {
  final String cardId;
  final String front;
  final String back;
  final String? phonetic;
  final String? exampleSentence;
  final String? imageUrl;
  final String? audioUrl;
  final int? orderIndex;

  const StudyCardResponse({
    required this.cardId,
    required this.front,
    required this.back,
    this.phonetic,
    this.exampleSentence,
    this.imageUrl,
    this.audioUrl,
    this.orderIndex,
  });

  /// JSON -> StudyCardResponse
  factory StudyCardResponse.fromJson(Map<String, dynamic> json) {
    return StudyCardResponse(
      cardId: json['cardId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      phonetic: json['phonetic'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      orderIndex: json['orderIndex'] as int?,
    );
  }

  /// StudyCardResponse -> JSON
  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'front': front,
      'back': back,
      'phonetic': phonetic,
      'exampleSentence': exampleSentence,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'orderIndex': orderIndex,
    };
  }
}
