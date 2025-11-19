import 'package:flutter/material.dart';
import 'dart:async';

class EndingCreditsScreen extends StatefulWidget {
  const EndingCreditsScreen({super.key});

  @override
  State<EndingCreditsScreen> createState() => _EndingCreditsScreenState();
}

class _EndingCreditsScreenState extends State<EndingCreditsScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _fadeController.forward();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 60),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      body: Stack(
        children: [
          _buildStarfield(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
                child: Column(
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 80),
                    _buildSection('최종 진화 달성', [
                      '아빠 허태훈',
                    ], large: true),
                    const SizedBox(height: 100),
                    _buildQuote(),
                    const SizedBox(height: 100),
                    _buildSection('기획 및 개발', [
                      '이다겸',
                    ]),
                    const SizedBox(height: 60),
                    _buildSection('프로젝트 구조', [
                      'Frontend - Flutter',
                      'Backend - Spring Boot',
                      'AI Service - Python + GPT-4',
                      'Database - PostgreSQL',
                    ]),
                    const SizedBox(height: 60),
                    _buildSection('핵심 기능', [
                      '🎮 RPG 게임화 학습 시스템',
                      '🤖 AI 동적 퀴즈 생성',
                      '😡 허태훈의 분노 게이지',
                      '💪 멘탈 회복 미션',
                      '⚔️ 레이드 협동 보스전',
                      '🎭 캐릭터 커스터마이징',
                      '📊 실시간 클래스 랭킹',
                      '📖 분노의 추억 회상',
                      '👨 최종 진화: 아빠 허태훈',
                    ]),
                    const SizedBox(height: 60),
                    _buildSection('기술 스택', [
                      'Flutter 3.16.0',
                      'Spring Boot 3.2.0',
                      'PostgreSQL 16',
                      'OpenAI GPT-4',
                      'Tesseract OCR',
                      'Apache POI (Excel)',
                      'PDFBox',
                      'JWT Authentication',
                    ]),
                    const SizedBox(height: 60),
                    _buildSection('디자인', [
                      '조선굴림체 폰트',
                      '플랫 디자인',
                      '다크 테마 UI',
                      '색상 팔레트:',
                      '#00010D, #595048',
                      '#736A63, #D9D4D2',
                    ]),
                    const SizedBox(height: 80),
                    _buildSection('특별 감사', [
                      'class 422 친구들',
                      '영감의 원천 허태훈 강사님',
                      '영원한 한 팀 악귀멸살',
                      '그리고...',
                    ]),
                    const SizedBox(height: 60),
                    _buildFinalMessage(),
                    const SizedBox(height: 100),
                    _buildStats(),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFD9D4D2), size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarfield() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF00010D),
            const Color(0xFF000000),
          ],
        ),
      ),
      child: CustomPaint(
        painter: StarfieldPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.sentiment_very_satisfied,
            size: 100,
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          '허태훈의 분노 던전',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '최종 진화 완료',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontFamily: 'JoseonGulim',
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildQuote() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF595048).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Column(
        children: [
          Text(
            '"공부는 말이지...\n이 세상에서 제일 귀찮은 사랑이야..."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 24,
              fontStyle: FontStyle.italic,
              height: 1.8,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '- 아빠 허태훈',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, {bool large = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF4CAF50),
            fontFamily: 'JoseonGulim',
            fontSize: large ? 32 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                item,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: large ? 24 : 18,
                  height: 1.5,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildFinalMessage() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.2),
            const Color(0xFF2196F3).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.favorite, color: Color(0xFFFF5722), size: 48),
          SizedBox(height: 20),
          Text(
            '학습을 게임처럼,\n게임을 학습처럼',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF595048).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text(
            '프로젝트 통계',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontFamily: 'JoseonGulim',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: '개발 기간', value: '2주'),
              _StatItem(label: '코드 라인', value: '많음'),
              _StatItem(label: '파일 수', value: '많음'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontFamily: 'JoseonGulim',
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD9D4D2);

    for (int i = 0; i < 100; i++) {
      final x = (i * 123.456) % size.width;
      final y = (i * 456.789) % size.height;
      final radius = ((i * 0.123) % 2) + 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
