import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final String? bossId;
  final Student? student;
  
  const QuizScreen({super.key, this.bossId, this.student});
  
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  String? rageMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    if (widget.bossId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final quizzes = await ApiService.getQuizzes(widget.bossId!);
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('퀴즈를 불러올 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '퀴즈',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz, size: 80, color: Color(0xFF595048)),
                      const SizedBox(height: 24),
                      const Text(
                        '아직 준비된 퀴즈가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text(
                          '돌아가기',
                          style: TextStyle(
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                            color: Color(0xFFD9D4D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildQuestionCard(_quizzes[currentQuestionIndex]),
                        const SizedBox(height: 30),
                        if (!showResult) _buildOptions(_quizzes[currentQuestionIndex]),
                        if (showResult) _buildResultMessage(),
                        const SizedBox(height: 30),
                        if (!showResult) _buildSubmitButton(_quizzes[currentQuestionIndex]),
                        if (showResult) _buildNextButton(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '문제 ${currentQuestionIndex + 1}/${_quizzes.length}',
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 24,
              fontFamily: 'JoseonGulim',
            ),
          ),
          if (widget.student != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Lv.${widget.student!.level}',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontSize: 20,
                    fontFamily: 'JoseonGulim',
                  ),
                ),
                Text(
                  'EXP: ${widget.student!.exp}',
                  style: const TextStyle(
                    color: Color(0xFF736A63),
                    fontSize: 16,
                    fontFamily: 'JoseonGulim',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Quiz quiz) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF595048), width: 2),
      ),
      child: Text(
        quiz.question,
        style: const TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 22,
          height: 1.5,
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }

  Widget _buildOptions(Quiz quiz) {
    List<Map<String, String>> options = [
      {'key': 'A', 'text': quiz.optionA},
      {'key': 'B', 'text': quiz.optionB},
      {'key': 'C', 'text': quiz.optionC},
      {'key': 'D', 'text': quiz.optionD},
    ];

    return Column(
      children: options.map((option) => _buildOptionButton(option)).toList(),
    );
  }

  Widget _buildOptionButton(Map<String, String> option) {
    bool isSelected = selectedAnswer == option['key'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedAnswer = option['key'];
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF736A63) : const Color(0xFF595048),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF595048),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  option['key']!,
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JoseonGulim',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                option['text']!,
                style: const TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontSize: 18,
                  fontFamily: 'JoseonGulim',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Quiz quiz) {
    return ElevatedButton(
      onPressed: selectedAnswer == null
          ? null
          : () async {
              await _submitAnswer(quiz);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF595048),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        '제출하기',
        style: TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }

  Future<void> _submitAnswer(Quiz quiz) async {
    try {
      bool correct = selectedAnswer == quiz.correctAnswer;
      
      if (!correct) {
        final rage = await ApiService.getRandomRage();
        rageMessage = rage['message'];
      }
      
      setState(() {
        showResult = true;
        isCorrect = correct;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
    }
  }

  Widget _buildResultMessage() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFF595048) : const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? const Color(0xFFD9D4D2) : const Color(0xFF595048),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            isCorrect ? '정답!' : '오답!',
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'JoseonGulim',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isCorrect
                ? '잘했어! 계속 가자!'
                : (rageMessage ?? '틀렸어! 복습 좀 해라!'),
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 24,
              fontFamily: 'JoseonGulim',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    bool isLastQuestion = currentQuestionIndex >= _quizzes.length - 1;

    return ElevatedButton(
      onPressed: () {
        if (isLastQuestion) {
          Navigator.pop(context);
        } else {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
            showResult = false;
            rageMessage = null;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF595048),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        isLastQuestion ? '완료' : '다음 문제',
        style: const TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }
}
