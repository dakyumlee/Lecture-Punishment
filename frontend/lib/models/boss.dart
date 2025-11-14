class Boss {
  final String id;
  final String name;
  final int hpTotal;
  final int hpCurrent;
  final String difficulty;

  Boss({
    required this.id,
    required this.name,
    required this.hpTotal,
    required this.hpCurrent,
    required this.difficulty,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['id'],
      name: json['name'],
      hpTotal: json['hpTotal'],
      hpCurrent: json['hpCurrent'],
      difficulty: json['difficulty'],
    );
  }
}
