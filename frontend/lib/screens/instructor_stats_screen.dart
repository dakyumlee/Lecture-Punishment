import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InstructorStatsScreen extends StatefulWidget {
  const InstructorStatsScreen({super.key});

  @override
  State<InstructorStatsScreen> createState() => _InstructorStatsScreenState();
}

class _InstructorStatsScreenState extends State<InstructorStatsScreen> {
  Map<String, dynamic>? _instructor;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructorData();
  }

  Future<void> _loadInstructorData() async {
    try {
      final instructor = await ApiService.getInstructor();
      final stats = await ApiService.getInstructorStats();
      
      setState(() {
        _instructor = instructor;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading instructor data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '강사 정보',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _instructor == null
              ? const Center(
                  child: Text(
                    '강사 정보를 불러올 수 없습니다',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInstructorCard(),
                      const SizedBox(height: 24),
                      _buildStatsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInstructorCard() {
    final level = _instructor!['level'] ?? 1;
    final exp = _instructor!['exp'] ?? 0;
    final title = _instructor!['currentTitle'] ?? 'Lv.$level — 신입 강사';
    final expForNext = level * 100;
    final progress = exp / expForNext;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: const Color(0xFFD9D4D2), width: 3),
            ),
            child: Center(
              child: Text(
                level >= 10 ? '👨‍👦' : '😤',
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _instructor!['name'] ?? '허태훈',
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXP: $exp / $expForNext',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
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
                  value: progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFF0D0D0D),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD9D4D2)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF595048), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '통계',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('총 학생 수', '${_stats!['totalStudents'] ?? 0}명'),
          _buildStatRow('평균 정답률', '${_stats!['averageCorrectRate'] ?? 0}%'),
          _buildStatRow('총 퀴즈 수', '${_stats!['totalQuizzes'] ?? 0}개'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
