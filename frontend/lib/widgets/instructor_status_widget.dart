import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InstructorStatusWidget extends StatefulWidget {
  const InstructorStatusWidget({super.key});

  @override
  State<InstructorStatusWidget> createState() => _InstructorStatusWidgetState();
}

class _InstructorStatusWidgetState extends State<InstructorStatusWidget> {
  Map<String, dynamic>? _instructorStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructorStats();
  }

  Future<void> _loadInstructorStats() async {
    try {
      final stats = await ApiService.getInstructorStats();
      setState(() {
        _instructorStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        color: Color(0xFF595048),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2))),
        ),
      );
    }

    if (_instructorStats == null) {
      return const SizedBox();
    }

    int level = _instructorStats!['level'] ?? 1;
    int exp = _instructorStats!['exp'] ?? 0;
    int rageGauge = _instructorStats!['rageGauge'] ?? 0;
    bool isEvolved = _instructorStats!['isEvolved'] ?? false;
    String statusMessage = _instructorStats!['statusMessage'] ?? '';

    return Card(
      color: const Color(0xFF595048),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isEvolved ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEvolved ? '👨‍👦 아빠 허태훈' : '👨‍🏫 허태훈 강사',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFD9D4D2)),
                  onPressed: _loadInstructorStats,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusMessage,
              style: const TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow('레벨', 'Lv.$level'),
            const SizedBox(height: 12),
            _buildProgressBar('경험치', exp, 100, Colors.blue),
            const SizedBox(height: 12),
            if (!isEvolved)
              _buildProgressBar(
                '분노 게이지',
                rageGauge,
                100,
                rageGauge >= 80
                    ? Colors.red
                    : rageGauge >= 50
                        ? Colors.orange
                        : Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, int current, int max, Color color) {
    double percent = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
            Text(
              '$current / $max',
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 20,
              width: MediaQuery.of(context).size.width * 0.8 * percent,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
