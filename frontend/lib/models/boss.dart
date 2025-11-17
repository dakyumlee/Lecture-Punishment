class Boss {
  final String id;
  final String name;
  final int hpTotal;
  int hpCurrent;
  bool isDefeated;

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
      name: json['bossName'] ?? json['name'] ?? '알 수 없는 보스',
      hpTotal: json['totalHp'] ?? json['hpTotal'] ?? 1000,
      hpCurrent: json['currentHp'] ?? json['hpCurrent'] ?? 1000,
      isDefeated: json['isDefeated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hpTotal': hpTotal,
      'hpCurrent': hpCurrent,
      'isDefeated': isDefeated,
    };
  }
}
