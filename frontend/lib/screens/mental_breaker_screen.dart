import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class MentalBreakerScreen extends StatefulWidget {
  final Student student;
  const MentalBreakerScreen({super.key, required this.student});

  @override
  State<MentalBreakerScreen> createState() => _MentalBreakerScreenState();
}

class _MentalBreakerScreenState extends State<MentalBreakerScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _mentalState;
  bool _isLoading = true;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadMentalState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadMentalState() async {
    setState(() => _isLoading = true);
    try {
      final state = await ApiService.getMentalState(widget.student.id);
      setState(() {
        _mentalState = state;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getMentalColor(int gauge) {
    if (gauge <= 20) return const Color(0xFFFF5722);
    if (gauge <= 40) return const Color(0xFFFF9800);
    if (gauge <= 70) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case '멘탈붕괴': return Icons.sentiment_very_dissatisfied;
      case '위기': return Icons.sentiment_dissatisfied;
      case '불안': return Icons.sentiment_neutral;
      case '안정': return Icons.sentiment_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '🧠 멘탈 브레이커',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _mentalState == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Text(
        '멘탈 상태를 불러올 수 없습니다',
        style: TextStyle(
          color: Color(0xFF736A63),
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }

  Widget _buildContent() {
    final mentalGauge = _mentalState!['mentalGauge'] ?? 100;
    final mood = _mentalState!['mood'] ?? '보통';
    final isInCrisis = _mentalState!['isInCrisis'] ?? false;
    final consecutiveWrongs = _mentalState!['consecutiveWrongs'] ?? 0;
    final totalBreakdowns = _mentalState!['totalBreakdowns'] ?? 0;
    final totalRecoveries = _mentalState!['totalRecoveries'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMentalGauge(mentalGauge, mood, isInCrisis),
          _buildStats(consecutiveWrongs, totalBreakdowns, totalRecoveries),
          _buildDescription(),
          if (isInCrisis) _buildCrisisWarning(),
        ],
      ),
    );
  }

  Widget _buildMentalGauge(int gauge, String mood, bool isInCrisis) {
    final color = _getMentalColor(gauge);
    final icon = _getMoodIcon(mood);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: isInCrisis ? Offset(_shakeAnimation.value, 0) : Offset.zero,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF595048),
              borderRadius: BorderRadius.circular(24),
              border: isInCrisis ? Border.all(color: Colors.red, width: 3) : null,
            ),
            child: Column(
              children: [
                Icon(icon, size: 80, color: color),
                const SizedBox(height: 16),
                Text(
                  mood,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'JoseonGulim',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.7 * (gauge / 100),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.7), color],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$gauge / 100',
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(int consecutiveWrongs, int totalBreakdowns, int totalRecoveries) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '멘탈 통계',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('연속 오답', '$consecutiveWrongs회', Icons.close, const Color(0xFFFF5722)),
              _buildStatItem('총 멘붕', '$totalBreakdowns회', Icons.warning, const Color(0xFFFF9800)),
              _buildStatItem('회복 횟수', '$totalRecoveries회', Icons.favorite, const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: 'JoseonGulim',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                '멘탈 브레이커란?',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '문제를 틀릴 때마다 허태훈의 심리전이 시작됩니다.\n'
            '멘탈 게이지가 떨어지면 AI가 생성한 맞춤형 분노 대사가 나옵니다.\n\n'
            '- 연속 오답 시 멘탈 데미지 증가\n'
            '- 멘탈 게이지 20 이하 시 멘탈붕괴\n'
            '- 멘탈 회복 미션으로 회복 가능\n'
            '- 정답 시 멘탈 자동 회복',
            style: TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisWarning() {
    _shakeController.repeat(reverse: true);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5722),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                '멘탈 붕괴 경고!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'JoseonGulim',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '멘탈 회복 미션을 완료하세요',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'JoseonGulim',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
