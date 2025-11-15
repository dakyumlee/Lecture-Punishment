import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final student = provider.currentStudent;

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '퀴즈 완료!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '정답: ${provider.correctCount} / $totalQuestions',
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '오답: ${provider.wrongCount}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  if (student != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(initialStudent: student),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595048),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  '홈으로',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}