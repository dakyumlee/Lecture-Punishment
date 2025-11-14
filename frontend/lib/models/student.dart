class Student {
  final String id;
  final String username;
  final String displayName;
  final int exp;
  final int level;
  final int points;
  final bool isProfileComplete;

  Student({
    required this.id,
    required this.username,
    required this.displayName,
    required this.exp,
    required this.level,
    required this.points,
    required this.isProfileComplete,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'] ?? '',
      exp: json['exp'] ?? 0,
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }
}
