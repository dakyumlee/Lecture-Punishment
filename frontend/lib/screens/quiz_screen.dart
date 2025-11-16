import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  String? rageMessage;
  String? praiseMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00010D),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)));
          }

          if (gameProvider.quizzes.isEmpty) {
            return Center(
              child: Text(
                '퀴즈가 없습니다',
                style: TextStyle(color: Color(0xFFD9D4D2), fontSize: 24),
              ),
            );
          }

          Quiz currentQuiz = gameProvider.quizzes[currentQuestionIndex];

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(gameProvider),
                  SizedBox(height: 20),
                  _buildQuestionCard(currentQuiz),
                  SizedBox(height: 30),
                  if (!showResult) _buildOptions(currentQuiz),
                  if (showResult) _buildResultMessage(),
                  SizedBox(height: 30),
                  if (!showResult) _buildSubmitButton(gameProvider, currentQuiz),
                  if (showResult) _buildNextButton(gameProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(GameProvider gameProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '문제 ${currentQuestionIndex + 1}/${gameProvider.quizzes.length}',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 24,
              fontFamily: 'JoseonGulim',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Lv.${gameProvider.currentStudent?.level ?? 1}',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontSize: 20,
                  fontFamily: 'JoseonGulim',
                ),
              ),
              Text(
                'EXP: ${gameProvider.currentStudent?.exp ?? 0}',
                style: TextStyle(
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
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF595048), width: 2),
      ),
      child: Text(
        quiz.question,
        style: TextStyle(
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
      padding: EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedAnswer = option['key'];
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xFF736A63) : Color(0xFF595048),
          padding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isSelected ? Color(0xFFD9D4D2) : Color(0xFF595048),
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
                color: Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  option['key']!,
                  style: TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JoseonGulim',
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                option['text']!,
                style: TextStyle(
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

  Widget _buildSubmitButton(GameProvider gameProvider, Quiz quiz) {
    return ElevatedButton(
      onPressed: selectedAnswer == null
          ? null
          : () async {
              var result = await gameProvider.submitAnswer(quiz.id, selectedAnswer!);
              setState(() {
                showResult = true;
                isCorrect = result['isCorrect'];
                rageMessage = result['rageMessage'];
                praiseMessage = result['message'];
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF595048),
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
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

  Widget _buildResultMessage() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isCorrect ? Color(0xFF595048) : Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? Color(0xFFD9D4D2) : Color(0xFF595048),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            isCorrect ? '정답!' : '오답!',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 20),
          Text(
            isCorrect
                ? (praiseMessage ?? '잘했어!')
                : (rageMessage ?? '틀렸어!'),
            style: TextStyle(
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

  Widget _buildNextButton(GameProvider gameProvider) {
    bool isLastQuestion = currentQuestionIndex >= gameProvider.quizzes.length - 1;

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
            praiseMessage = null;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF595048),
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        isLastQuestion ? '완료' : '다음 문제',
        style: TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }
}
