import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/student.dart';
import 'quiz_screen.dart';
class DungeonScreen extends StatelessWidget {
  final Student student;
  const DungeonScreen({super.key, required this.student});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '던전',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          if (provider.currentBoss == null) {
            return const Center(
              child: Text(
                '보스를 찾을 수 없습니다',
                style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.currentBoss!.name,
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                        'HP: ${provider.currentBoss!.hpCurrent} / ${provider.currentBoss!.hpTotal}',
                          color: Color(0xFF736A63),
                          fontSize: 18,
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(student: student),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595048),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  child: const Text(
                    '퀴즈 시작',
                    style: TextStyle(
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      color: Color(0xFFD9D4D2),
                    ),
            ],
          );
        },
    );
  }
}
