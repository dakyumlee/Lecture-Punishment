class Quiz {
  final String id;
  final String question;
  final String? questionType;
  final List<String>? options;
  final String? correctAnswer;

  Quiz({
    required this.id,
    required this.question,
    this.questionType,
    this.options,
    this.correctAnswer,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      question: json['question'],
      questionType: json['questionType'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correctAnswer'],
    );
  }
}
