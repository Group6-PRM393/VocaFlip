class QuizOption {
  final String optionId;
  final String content;

  QuizOption({required this.optionId, required this.content});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(optionId: json['optionId'], content: json['content']);
  }
}
