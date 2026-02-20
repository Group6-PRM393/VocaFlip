/// Model đại diện cho một thẻ flashcard trong bộ Deck.
/// Chứa thông tin mặt trước (term) và mặt sau (definition, ipa, example).
class FlashcardModel {
  final String id;
  final String term; // Từ vựng / Thuật ngữ (hiển thị mặt trước)
  final String definition; // Nghĩa / Giải thích (hiển thị mặt sau)
  final String? ipa; // Phiên âm quốc tế (IPA)
  final String? example; // Câu ví dụ (tuỳ chọn)
  final String? imageUrl; // Hình ảnh minh hoạ (tuỳ chọn)
  final String? audioUrl; // URL phát âm (tuỳ chọn)

  const FlashcardModel({
    required this.id,
    required this.term,
    required this.definition,
    this.ipa,
    this.example,
    this.imageUrl,
    this.audioUrl,
  });

  /// Tạo FlashcardModel từ JSON (khi gọi API)
  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      term: json['term'] as String,
      definition: json['definition'] as String,
      ipa: json['ipa'] as String?,
      example: json['example'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  /// Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'ipa': ipa,
      'example': example,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }
}
