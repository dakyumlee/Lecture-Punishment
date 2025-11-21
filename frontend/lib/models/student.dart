class Student {
  final String id;
  final String username;
  final String displayName;
  int exp;
  int level;
  final int points;
  final int mentalGauge;
  final bool isProfileComplete;
  final int? totalCorrect;
  final int? totalWrong;
  final String? characterExpression;
  final String? characterOutfit;
  final String? birthDate;
  final String? phoneNumber;
  final String? studentIdNumber;

  Student({
    required this.id,
    required this.username,
    required this.displayName,
    required this.exp,
    required this.level,
    required this.points,
    required this.mentalGauge,
    required this.isProfileComplete,
    this.totalCorrect,
    this.totalWrong,
    this.characterExpression,
    this.characterOutfit,
    this.birthDate,
    this.phoneNumber,
    this.studentIdNumber,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'] ?? '',
      exp: json['exp'] ?? 0,
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      mentalGauge: json['mentalGauge'] ?? 100,
      isProfileComplete: json['isProfileComplete'] ?? false,
      totalCorrect: json['totalCorrect'],
      totalWrong: json['totalWrong'],
      characterExpression: json['characterExpression'],
      characterOutfit: json['characterOutfit'],
      birthDate: json['birthDate'],
      phoneNumber: json['phoneNumber'],
      studentIdNumber: json['studentIdNumber'],
    );
  }
}
