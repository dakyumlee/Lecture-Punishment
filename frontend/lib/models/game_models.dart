class Instructor {
  final String id;
  final String name;
  final int level;
  final int exp;
  final int rageGauge;
  final String evolutionStage;

  Instructor({
    required this.id,
    required this.name,
    required this.level,
    required this.exp,
    required this.rageGauge,
    required this.evolutionStage,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? 1,
      exp: json['exp'] ?? 0,
      rageGauge: json['rageGauge'] ?? json['rage_gauge'] ?? 0,
      evolutionStage: json['evolutionStage'] ?? json['evolution_stage'] ?? 'normal',
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String subject;

  Lesson({
    required this.id,
    required this.title,
    required this.subject,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
    );
  }
}

class Boss {
  final String id;
  final String name;
  final int hpTotal;
  final int hpCurrent;
  final bool isDefeated;

  Boss({
    required this.id,
    required this.name,
    required this.hpTotal,
    required this.hpCurrent,
    required this.isDefeated,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      hpTotal: json['hpTotal'] ?? json['hp_total'] ?? 100,
      hpCurrent: json['hpCurrent'] ?? json['hp_current'] ?? 100,
      isDefeated: json['isDefeated'] ?? json['is_defeated'] ?? false,
    );
  }
}

class Quiz {
  final String id;
  final String question;
  final String correctAnswer;

  Quiz({
    required this.id,
    required this.question,
    required this.correctAnswer,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      correctAnswer: json['correctAnswer'] ?? json['correct_answer'] ?? '',
    );
  }
}
