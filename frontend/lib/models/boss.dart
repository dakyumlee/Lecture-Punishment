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
      name: json['name'] ?? '알 수 없는 보스',
      hpTotal: json['hpTotal'] ?? 1000,
      hpCurrent: json['hpCurrent'] ?? 1000,
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