class CardModel {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? phonetic;
  final String? exampleSentence;
  final String? audioUrl;
  final String? imageUrl;

  CardModel({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.phonetic,
    required this.exampleSentence,
    required this.audioUrl,
    required this.imageUrl,
  });

 factory CardModel.fromJson(Map<String, dynamic> json) {
  String s(dynamic v) => (v ?? '').toString();

  return CardModel(
    id: s(json['id']),
    deckId: s(json['deckId']),
    front: s(json['front']),        // null -> ''
    back: s(json['back']),          // null -> ''
    phonetic: json['phonetic']?.toString(),
    exampleSentence: json['exampleSentence']?.toString(),
    audioUrl: json['audioUrl']?.toString(),
    imageUrl: json['imageUrl']?.toString(),
  );
}

}
