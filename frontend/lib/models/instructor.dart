class Instructor {
  final String id;
  final String name;
  final String username;
  final int level;
  final int exp;
  final int rageGauge;

  Instructor({
    required this.id,
    required this.name,
    required this.username,
    required this.level,
    required this.exp,
    required this.rageGauge,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      level: json['level'],
      exp: json['exp'],
      rageGauge: json['rageGauge'],
    );
  }
}
