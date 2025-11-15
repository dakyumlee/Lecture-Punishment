import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../theme/app_theme.dart';

class RageDialogueWidget extends StatelessWidget {
  final String dialogue;
  final bool isCorrect;

  const RageDialogueWidget({
    super.key,
    required this.dialogue,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isCorrect ? Colors.green[900] : Colors.red[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.error,
            size: 120,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            color: AppTheme.primaryDark,
            child: Column(
              children: [
                Text(
                  isCorrect ? '허태훈의 감탄' : '허태훈의 분노',
                  style: const TextStyle(
                    color: AppTheme.lightGray,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  dialogue,
                  style: TextStyle(
                    color: isCorrect ? Colors.green[200] : Colors.red[200],
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
