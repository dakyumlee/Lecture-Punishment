import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/student.dart';
import '../models/boss.dart';
import '../services/api_service.dart';
import 'mental_recovery_screen.dart';

class QuizScreen extends StatefulWidget {
  final String? bossId;
  final Student? student;
  
  const QuizScreen({super.key, this.bossId, this.student});
  
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  List<Quiz> _quizzes = [];
  Boss? _boss;
  Student? _student;
  bool _isLoading = true;
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  String? rageMessage;
  int combo = 0;
  int currentPoints = 0;
  int earnedPoints = 0;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    currentPoints = _student?.points ?? 0;
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.bossId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final quizzes = await ApiService.getQuizzes(widget.bossId!);
      final boss = await ApiService.getBoss(widget.bossId!);
      
      setState(() {
        _quizzes = quizzes;
        _boss = boss;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러올 수 없습니다: $e')),
        );
      }
    }
  }


  void _showMentalRecoveryDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.red, width: 3),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '⚠️ 멘탈 붕괴 위험!',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'JoseonGulim',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '멘탈 게이지: ${_student!.mentalGauge}/100',
                style: const TextStyle(
                  color: Colors.red,
                  fontFamily: 'JoseonGulim',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '멘탈이 너무 낮습니다!\n회복 미션을 진행하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '나중에',
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MentalRecoveryScreen(student: _student!),
                ),
              );
              
              if (result == true && mounted) {
                final updatedStudent = await ApiService().getStudent(_student!.id);
                setState(() {
                  _student = updatedStudent;
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '멘탈이 회복되었습니다!',
                        style: TextStyle(fontFamily: 'JoseonGulim'),
                      ),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '회복 미션 시작',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'JoseonGulim',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '퀴즈 배틀',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _quizzes.isEmpty
              ? _buildEmptyState()
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 12),
                          if (_boss != null) _buildBossHpBar(),
                          const SizedBox(height: 12),
                          if (_student != null) _buildMentalGaugeBar(),
                          const SizedBox(height: 12),
                          if (combo >= 3) _buildComboIndicator(),
                          const SizedBox(height: 20),
                          _buildQuestionCard(_quizzes[currentQuestionIndex]),
                          const SizedBox(height: 30),
                          if (!showResult) _buildOptions(_quizzes[currentQuestionIndex]),
                          if (showResult) _buildResultMessage(),
                          const SizedBox(height: 30),
                          if (!showResult) _buildSubmitButton(_quizzes[currentQuestionIndex]),
                          if (showResult) _buildNextButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '문제 ${currentQuestionIndex + 1}/${_quizzes.length}',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontSize: 24,
                      fontFamily: 'JoseonGulim',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (combo > 0)
                    Text(
                      '🔥 $combo 콤보!',
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontSize: 16,
                        fontFamily: 'JoseonGulim',
                      ),
                    ),
                ],
              ),
              if (_student != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lv.${_student!.level}',
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontSize: 20,
                        fontFamily: 'JoseonGulim',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'EXP: ${_student!.exp}/100',
                      style: const TextStyle(
                        color: Color(0xFF736A63),
                        fontSize: 14,
                        fontFamily: 'JoseonGulim',
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFD9D4D2), size: 20),
                const SizedBox(width: 8),
                Text(
                  '$currentPoints P',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontSize: 18,
                    fontFamily: 'JoseonGulim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossHpBar() {
    double hpPercent = _boss!.hpCurrent / _boss!.hpTotal;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF595048), width: 2),
      ),
      child: Column(
        children: [
          Text(
            _boss!.name,
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 18,
              fontFamily: 'JoseonGulim',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF595048),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 24,
                    width: constraints.maxWidth * hpPercent,
                    decoration: BoxDecoration(
                      color: hpPercent > 0.5 ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Container(
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      '${_boss!.hpCurrent} / ${_boss!.hpTotal}',
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontSize: 12,
                        fontFamily: 'JoseonGulim',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildMentalGaugeBar() {
    final mental = _student!.mentalGauge;
    final mentalPercent = mental / 100;
    
    Color gaugeColor;
    String status;
    
    if (mental >= 80) {
      gaugeColor = const Color(0xFF4CAF50);
      status = '😊 양호';
    } else if (mental >= 60) {
      gaugeColor = const Color(0xFF8BC34A);
      status = '😐 보통';
    } else if (mental >= 40) {
      gaugeColor = const Color(0xFFFF9800);
      status = '😰 불안';
    } else if (mental >= 30) {
      gaugeColor = const Color(0xFFFF5722);
      status = '😱 위험';
    } else {
      gaugeColor = const Color(0xFFD32F2F);
      status = '💀 붕괴';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mental < 30 ? Colors.red : const Color(0xFF736A63),
          width: mental < 30 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFD9D4D2), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '멘탈 게이지',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                status,
                style: TextStyle(
                  color: gaugeColor,
                  fontFamily: 'JoseonGulim',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mentalPercent,
              minHeight: 12,
              backgroundColor: const Color(0xFF595048),
              valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$mental / 100',
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 12,
            ),
          ),
          if (mental < 30)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '멘탈이 붕괴 직전입니다! 회복 미션을 진행하세요.',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'JoseonGulim',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComboIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF736A63), Color(0xFF595048)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉 허태훈의 감탄! 잘하고 있어! 🎉',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 18,
              fontFamily: 'JoseonGulim',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Quiz quiz) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        double shake = 0;
        if (_shakeController.isAnimating) {
          shake = Math.sin(_shakeController.value * 3.14159 * 4) * 10;
        }
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Container(
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
    if (_student == null || widget.bossId == null) return;
    
    try {
      bool correct = selectedAnswer == quiz.correctAnswer;
      
      if (correct) {
        int oldCombo = combo;
        combo++;
        
        final expResult = await ApiService.addStudentExp(_student!.id, 10);
        final statsResult = await ApiService.updateStudentStats(_student!.id, true);
        
        earnedPoints = statsResult['pointsEarned'] ?? 5;
        currentPoints += earnedPoints;
        
        if (_boss != null) {
          final bossResult = await ApiService.updateBossHp(widget.bossId!, 200);
          setState(() {
            _boss!.hpCurrent = bossResult['currentHp'];
            _boss!.isDefeated = bossResult['isDefeated'];
          });
          
          if (_boss!.isDefeated) {
            _showBossDefeatedDialog();
          }
        }
        
        setState(() {
          _student!.exp = expResult['student']['exp'];
          _student!.level = expResult['student']['level'];
        });
        
        if (combo >= 3) {
          final praise = await ApiService.getRageDialogue(
            dialogueType: 'combo_3',
            studentName: _student!.displayName,
            combo: combo,
          );
          rageMessage = praise['dialogue'];
        }
        
        if (expResult['leveledUp']) {
          _showLevelUpDialog(expResult['oldLevel'], expResult['newLevel']);
        }
      } else {
        int oldCombo = combo;
        combo = 0;
        await ApiService.updateStudentStats(_student!.id, false);
        
        String dialogueType = oldCombo >= 3 ? 'combo_broken' : 'wrong_answer';
        
        final rage = await ApiService.getRageDialogue(
          dialogueType: dialogueType,
          studentName: _student!.displayName,
          question: quiz.question,
          wrongAnswer: selectedAnswer ?? '',
          correctAnswer: quiz.correctAnswer,
          combo: oldCombo,
        );
        
        rageMessage = rage['dialogue'];
        _shakeController.forward(from: 0);
        earnedPoints = 0;
      }
      
      setState(() {
        showResult = true;
        isCorrect = correct;
      });
    } catch (e) {
      print('Submit answer error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
    }
  }

  void _showLevelUpDialog(int oldLevel, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '🎉 레벨 업! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lv.$oldLevel → Lv.$newLevel',
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '축하합니다!\n더욱 강해졌습니다!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFFD9D4D2), fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _showBossDefeatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '⚔️ 보스 처치! ⚔️',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_boss!.name}\n격파!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 훌륭합니다! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFFD9D4D2), fontSize: 18),
            ),
          ),
        ],
      ),
    );
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
            isCorrect ? '✅ 정답!' : '❌ 오답!',
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
                ? combo >= 3 
                    ? '완벽해! 이 기세로 계속 가자!'
                    : '잘했어! 계속 가자!'
                : (rageMessage ?? '틀렸어! 복습 좀 해라!'),
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 20,
              fontFamily: 'JoseonGulim',
            ),
            textAlign: TextAlign.center,
          ),
          if (isCorrect) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '💰 EXP +10',
                  style: TextStyle(
                    color: Color(0xFF736A63),
                    fontSize: 16,
                    fontFamily: 'JoseonGulim',
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFD9D4D2), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+$earnedPoints P',
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontSize: 16,
                          fontFamily: 'JoseonGulim',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    bool isLastQuestion = currentQuestionIndex >= _quizzes.length - 1;

    return ElevatedButton(
      onPressed: () {
        if (isLastQuestion) {
          _showFinalResults();
        } else {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
            showResult = false;
            rageMessage = null;
            earnedPoints = 0;
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
        isLastQuestion ? '결과 확인' : '다음 문제',
        style: const TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '🎊 퀴즈 완료! 🎊',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '총 ${_quizzes.length}문제 완료!',
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            if (_student != null)
              Column(
                children: [
                  Text(
                    '현재 레벨: Lv.${_student!.level}\nEXP: ${_student!.exp}/100',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Color(0xFFD9D4D2), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '보유 포인트: $currentPoints P',
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFFD9D4D2), fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
