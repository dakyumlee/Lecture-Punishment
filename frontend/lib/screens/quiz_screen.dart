import '../providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;
  
  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  int _currentQuizIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).loadQuizzes(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF00010D),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
            ),
          );
        }

        if (provider.quizzes.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFF00010D),
            body: Center(
              child: Text(
                '퀴즈가 없습니다',
                style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              ),
            ),
          );
        }

        final quiz = provider.quizzes[_currentQuizIndex];

        return Scaffold(
          backgroundColor: const Color(0xFF00010D),
          appBar: AppBar(
            title: const Text(
              '퀴즈',
              style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
            ),
            backgroundColor: const Color(0xFF00010D),
            iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '문제 ${_currentQuizIndex + 1} / ${provider.quizzes.length}',
                  style: const TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  quiz.question,
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _answerController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    hintText: '답을 입력하세요',
                    hintStyle: TextStyle(color: Color(0xFF736A63)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF595048)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                    ),
                  ),
                  onSubmitted: (_) => _submitAnswer(provider),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitAnswer(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595048),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Color(0xFFD9D4D2))
                      : const Text(
                          '제출',
                          style: TextStyle(
                            fontFamily: 'JoseonGulim',
                            fontSize: 20,
                            color: Color(0xFFD9D4D2),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitAnswer(GameProvider provider) async {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답을 입력하세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      await provider.submitAnswer(
        provider.quizzes[_currentQuizIndex].id,
        _answerController.text,
      );

      if (_currentQuizIndex < provider.quizzes.length - 1) {
        setState(() {
          _currentQuizIndex++;
          _answerController.clear();
          _isSubmitting = false;
        });
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                score: provider.currentScore,
                totalQuestions: provider.quizzes.length,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
