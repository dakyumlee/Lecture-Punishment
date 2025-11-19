import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RageMemoryScreen extends StatefulWidget {
  const RageMemoryScreen({super.key});

  @override
  State<RageMemoryScreen> createState() => _RageMemoryScreenState();
}

class _RageMemoryScreenState extends State<RageMemoryScreen> {
  List<Map<String, dynamic>> _memories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/instructor/rage-history?limit=50');
      
      if (response.statusCode == 200) {
        final data = response.data as List;
        setState(() {
          _memories = data.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '분노의 추억을 불러올 수 없습니다';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '네트워크 오류: $e';
        _isLoading = false;
      });
    }
  }

  Color _getIntensityColor(int intensity) {
    if (intensity >= 8) return const Color(0xFFFF5722);
    if (intensity >= 5) return const Color(0xFFFF9800);
    return const Color(0xFFFFC107);
  }

  IconData _getIntensityIcon(int intensity) {
    if (intensity >= 8) return Icons.local_fire_department;
    if (intensity >= 5) return Icons.whatshot;
    return Icons.emoji_emotions;
  }

  String _getRelativeTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()}달 전';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}일 전';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}시간 전';
      } else {
        return '방금';
      }
    } catch (e) {
      return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '📖 분노의 추억',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMemories,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildMemoryList(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFD9D4D2)),
          SizedBox(height: 24),
          Text(
            '추억을 불러오는 중...',
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Color(0xFFFF5722),
          ),
          const SizedBox(height: 24),
          Text(
            _error ?? '오류가 발생했습니다',
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMemories,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF595048),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              '다시 시도',
              style: TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryList() {
    if (_memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_satisfied,
              size: 80,
              color: Color(0xFF736A63),
            ),
            const SizedBox(height: 24),
            const Text(
              '아직 분노의 추억이 없습니다',
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '문제를 틀려보세요!',
              style: TextStyle(
                color: Color(0xFF595048),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _memories.length,
            itemBuilder: (context, index) => _buildMemoryCard(_memories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final avgIntensity = _memories.isEmpty
        ? 0.0
        : _memories
                .map((m) => (m['intensityLevel'] ?? 5) as int)
                .reduce((a, b) => a + b) /
            _memories.length;

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
          const Text(
            '이건 아빠가 젊을 때 말이야...',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.history,
                '총 ${_memories.length}개',
                const Color(0xFF4CAF50),
              ),
              _buildStatItem(
                Icons.local_fire_department,
                '평균 강도 ${avgIntensity.toStringAsFixed(1)}',
                const Color(0xFFFF5722),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(Map<String, dynamic> memory) {
    final intensity = (memory['intensityLevel'] ?? 5) as int;
    final intensityColor = _getIntensityColor(intensity);
    final intensityIcon = _getIntensityIcon(intensity);
    final message = memory['dialogueText'] ?? memory['message'] ?? '...';
    final studentName = memory['studentName'] ?? '익명';
    final dialogueType = memory['dialogueType'] ?? '일반';
    final createdAt = memory['createdAt'] ?? DateTime.now().toIso8601String();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: intensityColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: intensityColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(intensityIcon, color: intensityColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF736A63),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dialogueType,
                              style: const TextStyle(
                                color: Color(0xFFD9D4D2),
                                fontFamily: 'JoseonGulim',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRelativeTime(createdAt),
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: intensityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '강도 $intensity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JoseonGulim',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💬',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
