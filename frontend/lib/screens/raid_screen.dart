import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../models/student.dart';

class RaidScreen extends StatefulWidget {
  final Student student;
  const RaidScreen({super.key, required this.student});

  @override
  State<RaidScreen> createState() => _RaidScreenState();
}

class _RaidScreenState extends State<RaidScreen> {
  int _bossHp = 10000;
  int _totalHp = 10000;
  int _timeRemaining = 600;
  Timer? _timer;
  bool _isRaidActive = false;
  bool _isLoadingQuiz = false;

  Map<String, dynamic>? _currentQuiz;
  int _questionsAnswered = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRaid() {
    setState(() {
      _isRaidActive = true;
      _bossHp = _totalHp;
      _timeRemaining = 600;
      _questionsAnswered = 0;
    });

    _loadNextQuiz();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && _bossHp > 0) {
        setState(() => _timeRemaining--);
      } else {
        _endRaid();
      }
    });
  }

  void _endRaid() {
    _timer?.cancel();
    setState(() => _isRaidActive = false);

    if (_bossHp <= 0) {
      _showResultDialog(true);
    } else {
      _showResultDialog(false);
    }
  }

  Future<void> _loadNextQuiz() async {
    setState(() => _isLoadingQuiz = true);

    try {
      final topics = ['자료구조', '알고리즘', '운영체제', '네트워크', '데이터베이스'];
      final randomTopic = topics[DateTime.now().millisecond % topics.length];
      final difficulty = (_questionsAnswered ~/ 3) + 1;

      final quiz = await ApiService.generateRaidQuiz(
        topic: randomTopic,
        difficulty: difficulty.clamp(1, 5),
      );

      setState(() {
        _currentQuiz = quiz;
        _isLoadingQuiz = false;
      });
    } catch (e) {
      setState(() => _isLoadingQuiz = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '문제 로드 실패: $e',
              style: const TextStyle(fontFamily: 'JoseonGulim'),
            ),
            backgroundColor: const Color(0xFFFF5722),
          ),
        );
      }
    }
  }

  Future<void> _submitAnswer(String answer) async {
    if (_currentQuiz == null) return;

    setState(() => _isLoadingQuiz = true);

    try {
      final result = await ApiService.checkRaidAnswer(
        question: _currentQuiz!['question'] ?? '',
        answer: answer,
        correctAnswer: _currentQuiz!['correctAnswer'] ?? '',
      );

      final isCorrect = result['isCorrect'] ?? false;
      final damage = result['damage'] ?? 0;

      setState(() {
        _questionsAnswered++;
        if (isCorrect && damage > 0) {
          _bossHp = ((_bossHp - damage).clamp(0, _totalHp)).toInt();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCorrect ? '정답! 보스에게 $damage 데미지!' : '오답! 데미지 없음',
              style: const TextStyle(fontFamily: 'JoseonGulim'),
            ),
            backgroundColor: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      if (_bossHp <= 0) {
        _endRaid();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _loadNextQuiz();
      }
    } catch (e) {
      setState(() => _isLoadingQuiz = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '답안 제출 실패: $e',
              style: const TextStyle(fontFamily: 'JoseonGulim'),
            ),
            backgroundColor: const Color(0xFFFF5722),
          ),
        );
      }
    }
  }

  void _showResultDialog(bool victory) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: victory ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              victory ? Icons.emoji_events : Icons.close,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 12),
            Text(
              victory ? '레이드 성공!' : '레이드 실패',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'JoseonGulim',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              victory
                  ? '보스를 물리쳤습니다!\n모든 참가자에게 보상 지급!'
                  : '시간 초과...\n다음 기회에 다시 도전하세요!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '풀은 문제: $_questionsAnswered개',
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
            if (victory) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '+500 EXP',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'JoseonGulim',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '+1000 포인트',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'JoseonGulim',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              '확인',
              style: TextStyle(
                color: victory ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
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
    final double hpPercent = _bossHp / _totalHp;
    final int minutes = _timeRemaining ~/ 60;
    final int seconds = _timeRemaining % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '⚔️ 레이드: 지식의 신전',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isRaidActive ? _buildRaidActive(hpPercent, minutes, seconds) : _buildRaidLobby(),
    );
  }

  Widget _buildRaidLobby() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 120, color: Color(0xFFD9D4D2)),
            const SizedBox(height: 32),
            const Text(
              '레이드 대기실',
              style: TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '협동 보스전\nAI가 실시간으로 문제 생성!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF595048),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: Color(0xFFD9D4D2)),
                      SizedBox(width: 12),
                      Text(
                        '필요 인원: 3명 이상',
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Color(0xFFD9D4D2)),
                      SizedBox(width: 12),
                      Text(
                        '제한 시간: 10분',
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFF4CAF50)),
                      SizedBox(width: 12),
                      Text(
                        'AI 실시간 문제 생성',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontFamily: 'JoseonGulim',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                      SizedBox(width: 12),
                      Text(
                        '보상: 500 EXP + 1000P',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontFamily: 'JoseonGulim',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startRaid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '레이드 시작',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'JoseonGulim',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaidActive(double hpPercent, int minutes, int seconds) {
    return Column(
      children: [
        _buildBossSection(hpPercent, minutes, seconds),
        Expanded(
          child: _isLoadingQuiz ? _buildLoadingQuiz() : _buildQuizSection(),
        ),
      ],
    );
  }

  Widget _buildBossSection(double hpPercent, int minutes, int seconds) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '보스: 허태훈의 분노',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '풀은 문제: $_questionsAnswered개',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'JoseonGulim',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_bossHp / $_totalHp',
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(hpPercent * 100).toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: hpPercent,
                        minHeight: 20,
                        backgroundColor: const Color(0xFF0D0D0D),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          hpPercent > 0.5
                              ? Colors.green
                              : hpPercent > 0.25
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingQuiz() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFD9D4D2)),
          SizedBox(height: 24),
          Text(
            'AI가 문제를 생성중...',
            style: TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSection() {
    if (_currentQuiz == null) {
      return const Center(
        child: Text(
          '문제를 불러올 수 없습니다',
          style: TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
            fontSize: 16,
          ),
        ),
      );
    }

    final question = _currentQuiz!['question'] ?? '';
    final options = _currentQuiz!['options'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF595048),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question,
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAnswerButton(option, index),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String text, int index) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoadingQuiz ? null : () => _submitAnswer(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF736A63),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFF595048),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
