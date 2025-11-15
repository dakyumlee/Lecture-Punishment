import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GradingScreen extends StatefulWidget {
  final Map<String, dynamic> submission;
  const GradingScreen({super.key, required this.submission});
  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  List<dynamic> _answers = [];
  bool _isLoading = true;
  final Map<String, int> _pointsControllers = {};

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    try {
      final data = await ApiService.getSubmissionDetail(widget.submission['id']);
      setState(() {
        _answers = data['answers'] ?? [];
        _isLoading = false;
      });
      for (var answer in _answers) {
        _pointsControllers[answer['id']] = answer['pointsEarned'] ?? 0;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _updateGrade(String answerId, bool isCorrect, int score) async {
    try {
      final success = await ApiService.gradeAnswer(answerId, isCorrect, score);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채점 완료')),
        );
        _loadAnswers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채점 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '채점',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _answers.length,
              itemBuilder: (context, index) {
                return _buildAnswerCard(_answers[index]);
              },
            ),
    );
  }

  Widget _buildAnswerCard(dynamic answer) {
    final questionText = answer['question']?['questionText'] ?? '문제 없음';
    final studentAnswer = answer['studentAnswer'] ?? '';
    final correctAnswer = answer['question']?['correctAnswer'] ?? '';
    final answerId = answer['id'];
    final isCorrect = answer['isCorrect'] ?? false;
    final pointsEarned = _pointsControllers[answerId] ?? 0;

    return Card(
      color: const Color(0xFF595048),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제',
              style: const TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              questionText,
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '학생 답안: $studentAnswer',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '정답: $correctAnswer',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                    ),
                    decoration: InputDecoration(
                      labelText: '점수',
                      labelStyle: const TextStyle(
                        color: Color(0xFF736A63),
                        fontFamily: 'JoseonGulim',
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0D0D0D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF595048)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _pointsControllers[answerId] = int.tryParse(value) ?? 0;
                      });
                    },
                    controller: TextEditingController(text: pointsEarned.toString()),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _updateGrade(answerId, true, pointsEarned),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CC00),
                    foregroundColor: const Color(0xFFD9D4D2),
                  ),
                  child: const Text('정답', style: TextStyle(fontFamily: 'JoseonGulim')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateGrade(answerId, false, 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: const Color(0xFFD9D4D2),
                  ),
                  child: const Text('오답', style: TextStyle(fontFamily: 'JoseonGulim')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}