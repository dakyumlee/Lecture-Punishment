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
  Map<String, dynamic>? _evolutionCheck;
  bool _isLoading = true;
  bool _isEvolving = false;

  @override
  void initState() {
    super.initState();
    _loadInstructorData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await ApiService.getInstructorStats();
      final evolutionCheck = await ApiService.checkEvolution();
      setState(() {
        _stats = stats;
        _evolutionCheck = evolutionCheck;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
  Widget _buildEvolutionCard() {
    if (_evolutionCheck == null) return const SizedBox();

    final bool isEvolved = _evolutionCheck!['isAlreadyEvolved'] ?? false;
    final bool canEvolve = _evolutionCheck!['canEvolve'] ?? false;
    final List<dynamic> reasons = _evolutionCheck!['reasons'] ?? [];

    if (isEvolved) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              '👨‍👦 아빠 허태훈',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'JoseonGulim',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '최종 진화 완료!',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '"공부는 말이지... 이 세상에서\n제일 귀찮은 사랑이야..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'JoseonGulim',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: canEvolve ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canEvolve ? const Color(0xFF4CAF50) : const Color(0xFF595048),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                canEvolve ? Icons.star : Icons.lock,
                color: canEvolve ? const Color(0xFF4CAF50) : const Color(0xFF736A63),
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '아빠 허태훈 진화',
                  style: TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!canEvolve && reasons.isNotEmpty) ...[
            const Text(
              '진화 조건:',
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFFFF5722),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      reason.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFF5722),
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          if (canEvolve) ...[
            const Text(
              '🎉 진화 조건을 모두 충족했습니다!',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEvolving ? null : _handleEvolution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isEvolving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '아빠 허태훈으로 진화하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleEvolution() async {
    setState(() => _isEvolving = true);
    
    try {
      final result = await ApiService.autoEvolve();
      
      if (result['evolved'] == true) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    '🎉 진화 성공! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'JoseonGulim',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result['message'] ?? '허태훈이 아빠로 진화했습니다!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontFamily: 'JoseonGulim',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '진화 실패: $e',
              style: const TextStyle(fontFamily: 'JoseonGulim'),
            ),
            backgroundColor: const Color(0xFFFF5722),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isEvolving = false);
      }
    }
  }

}
