import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/student.dart';
import 'result_screen.dart';
class QuizScreen extends StatefulWidget {
  final Student student;
  const QuizScreen({super.key, required this.student});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}
class _QuizScreenState extends State<QuizScreen> {
  int _currentQuizIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '퀴즈',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          if (provider.quizzes.isEmpty) {
            return const Center(
              child: Text(
                '퀴즈가 없습니다',
                style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              ),
            );
          }
          if (_currentQuizIndex >= provider.quizzes.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(student: widget.student),
                ),
              );
            });
            return const Center(child: CircularProgressIndicator());
          final quiz = provider.quizzes[_currentQuizIndex];
          return Padding(
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
                const SizedBox(height: 24),
                  quiz.question,
                    color: Color(0xFFD9D4D2),
                    fontSize: 24,
                const SizedBox(height: 32),
                TextField(
                  controller: _answerController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: InputDecoration(
                    hintText: '답을 입력하세요',
                    hintStyle: const TextStyle(color: Color(0xFF736A63)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF595048)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD9D4D2)),
                  onSubmitted: (_) => _submitAnswer(provider),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitAnswer(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595048),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
              ],
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
      _answerController.clear();
      setState(() {
        _currentQuizIndex++;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
  void dispose() {
    _answerController.dispose();
    super.dispose();
