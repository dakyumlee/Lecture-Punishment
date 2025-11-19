import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String subject;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.subject = '일반',
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _result;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _submitResult();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitResult() async {
    final provider = Provider.of<GameProvider>(context, listen: false);
    final student = provider.currentStudent;
    
    try {
      final result = await ApiService.submitQuizResult(
        studentId: student?.id,
        correctCount: provider.correctCount,
        totalQuestions: widget.totalQuestions,
        subject: widget.subject,
      );
      
      setState(() {
        _result = result;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      print('결과 제출 실패: $e');
      setState(() {
        _result = {
          'comment': '수고했다',
          'rewards': {'exp': 10, 'points': 100},
          'scorePercent': (provider.correctCount / widget.totalQuestions * 100).toDouble(),
        };
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Color _getScoreColor(double scorePercent) {
    if (scorePercent == 100) return const Color(0xFF4CAF50);
    if (scorePercent >= 80) return const Color(0xFF8BC34A);
    if (scorePercent >= 60) return const Color(0xFFFFEB3B);
    if (scorePercent >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }

  String _getScoreEmoji(double scorePercent) {
    if (scorePercent == 100) return '🎉';
    if (scorePercent >= 90) return '😊';
    if (scorePercent >= 80) return '👍';
    if (scorePercent >= 70) return '🤔';
    if (scorePercent >= 60) return '😐';
    if (scorePercent >= 50) return '😰';
    if (scorePercent >= 40) return '😭';
    return '💀';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final student = provider.currentStudent;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF00010D),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD9D4D2)),
              const SizedBox(height: 24),
              const Text(
                '허태훈이 채점 중...',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF736A63),
                  fontFamily: 'JoseonGulim',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final scorePercent = _result!['scorePercent'] ?? 0.0;
    final comment = _result!['comment'] ?? '수고했다';
    final rewards = _result!['rewards'] ?? {'exp': 0, 'points': 0};
    final exp = rewards['exp'] ?? 0;
    final points = rewards['points'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '체점 결과',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF595048),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _getScoreColor(scorePercent),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getScoreColor(scorePercent).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getScoreEmoji(scorePercent),
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${scorePercent.toInt()}',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(scorePercent),
                                fontFamily: 'JoseonGulim',
                                height: 1.0,
                              ),
                            ),
                            Text(
                              '%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(scorePercent),
                                fontFamily: 'JoseonGulim',
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          '${provider.correctCount} / ${widget.totalQuestions}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF595048), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '😤 허태훈의 한마디',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          comment,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF595048),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎁 획득 보상',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRewardItem('⚡', 'EXP', exp),
                            Container(
                              width: 2,
                              height: 40,
                              color: const Color(0xFF736A63),
                            ),
                            _buildRewardItem('💰', '포인트', points),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '홈으로',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(String emoji, String label, int value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
      ],
    );
  }
}
