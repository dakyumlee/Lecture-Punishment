class Student {
  final String id;
  final String username;
  final String displayName;
  final int level;
  final int exp;
  final int points;
  final int mentalGauge;
  final int totalCorrect;
  final int totalWrong;
  final String characterExpression;
  final String characterOutfit;

  Student({
    required this.id,
    required this.username,
    required this.displayName,
    required this.level,
    required this.exp,
    this.points = 0,
    this.mentalGauge = 100,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.characterExpression = 'normal',
    this.characterOutfit = 'default',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['display_name'] ?? '',
      level: json['level'] ?? 1,
      exp: json['exp'] ?? 0,
      points: json['points'] ?? 0,
      mentalGauge: json['mentalGauge'] ?? json['mental_gauge'] ?? 100,
      totalCorrect: json['totalCorrect'] ?? json['total_correct'] ?? 0,
      totalWrong: json['totalWrong'] ?? json['total_wrong'] ?? 0,
      characterExpression: json['characterExpression'] ?? json['character_expression'] ?? 'normal',
      characterOutfit: json['characterOutfit'] ?? json['character_outfit'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'level': level,
      'exp': exp,
      'points': points,
      'mentalGauge': mentalGauge,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'characterExpression': characterExpression,
      'characterOutfit': characterOutfit,
    };
  }
}
