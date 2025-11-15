class Quiz {
  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String? explanation;
  final int? difficultyLevel;

  Quiz({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
    this.difficultyLevel,
  });

  List<String> get options => [optionA, optionB, optionC, optionD];

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      optionA: json['optionA'] ?? '',
      optionB: json['optionB'] ?? '',
      optionC: json['optionC'] ?? '',
      optionD: json['optionD'] ?? '',
      correctAnswer: json['correctAnswer'] ?? 'A',
      explanation: json['explanation'],
      difficultyLevel: json['difficultyLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficultyLevel': difficultyLevel,
    };
  }
}