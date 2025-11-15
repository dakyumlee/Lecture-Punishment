import 'package:flutter/material.dart';
import '../services/api_service.dart';


class WorksheetResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String worksheetTitle;

  const WorksheetResultScreen({
    super.key,
    required this.result,
    required this.worksheetTitle,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = result['percentage'] ?? 0;
    final totalScore = result['totalScore'] ?? 0;
    final maxScore = result['maxScore'] ?? 0;
    final correctCount = result['correctCount'] ?? 0;
    final wrongCount = result['wrongCount'] ?? 0;
    final expGained = result['expGained'] ?? 0;
    final pointsGained = result['pointsGained'] ?? 0;
    final leveledUp = result['leveledUp'] ?? false;
    final rageMessage = result['rageMessage'];
    final encouragement = result['encouragement'];

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('채점 결과', 
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: percentage >= 80
                      ? [const Color(0xFFD9D4D2), const Color(0xFF736A63)]
                      : [const Color(0xFF595048), const Color(0xFF00010D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    worksheetTitle,
                    style: TextStyle(
                      color: percentage >= 80 ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: percentage >= 80 ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalScore / $maxScore점',
                    style: TextStyle(
                      color: percentage >= 80 ? const Color(0xFF00010D) : const Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (wrongCount > 0 && rageMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF595048),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade800, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '⚡ 허태훈의 분노 ⚡',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'JoseonGulim',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rageMessage,
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (wrongCount == 0 && encouragement != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF595048),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade600, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '✨ 허태훈의 칭찬 ✨',
                            style: TextStyle(
                              color: Colors.green,
                              fontFamily: 'JoseonGulim',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            encouragement,
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('정답', '$correctCount', Colors.green.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('오답', '$wrongCount', Colors.red.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('획득 EXP', '+$expGained', const Color(0xFF736A63)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('획득 포인트', '+$pointsGained', const Color(0xFF736A63)),
                      ),
                    ],
                  ),
                  if (leveledUp) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D4D2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎉 레벨 업! 🎉',
                            style: TextStyle(
                              color: Color(0xFF00010D),
                              fontFamily: 'JoseonGulim',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lv.${result['newLevel']}',
                            style: const TextStyle(
                              color: Color(0xFF00010D),
                              fontFamily: 'JoseonGulim',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF595048),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text(
                      '홈으로',
                      style: TextStyle(
                        fontFamily: 'JoseonGulim',
                        fontSize: 18,
                        color: Color(0xFFD9D4D2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: 'JoseonGulim',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
