import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../models/game_models.dart';
import '../theme/app_theme.dart';

class BossHpBar extends StatelessWidget {
  final Boss boss;

  const BossHpBar({
    super.key,
    required this.boss,
  });

  @override
  Widget build(BuildContext context) {
    final hpPercent = boss.hpPercentage / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.secondaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                boss.bossName,
                style: const TextStyle(
                  color: AppTheme.lightGray,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${boss.currentHp}/${boss.totalHp}',
                style: const TextStyle(
                  color: AppTheme.accentBrown,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 30,
                color: AppTheme.pureBlack,
              ),
              FractionallySizedBox(
                widthFactor: hpPercent,
                child: Container(
                  height: 30,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
