import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../models/student.dart';
import '../theme/app_theme.dart';
class StudentInfoWidget extends StatelessWidget {
  final Student student;
  const StudentInfoWidget({
    super.key,
    required this.student,
  });
  @override
  Widget build(BuildContext context) {
    final expPercent = (student.exp % 100) / 100;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.secondaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.displayName,
                    style: const TextStyle(
                      color: AppTheme.lightGray,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                    'Lv.${student.level}',
                      color: AppTheme.accentBrown,
                      fontSize: 18,
                ],
              ),
                crossAxisAlignment: CrossAxisAlignment.end,
                    '멘탈: ${student.mentalGauge}%',
                    style: TextStyle(
                      color: student.mentalGauge < 30 
                          ? Colors.red[300]
                          : AppTheme.lightGray,
                      fontSize: 16,
                    '정답률: ${student.accuracyRate.toStringAsFixed(1)}%',
                      fontSize: 14,
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              Text(
                'EXP ${student.exp}/100',
                style: const TextStyle(
                  color: AppTheme.lightGray,
                  fontSize: 12,
                ),
              const SizedBox(height: 4),
              Stack(
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: AppTheme.pureBlack,
                  FractionallySizedBox(
                    widthFactor: expPercent,
                    child: Container(
                      height: 20,
                      color: Colors.blue[700],
        ],
      ),
    );
  }
}
