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
  final Map<String, TextEditingController> _pointsControllers = {};

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  @override
  void dispose() {
    for (var controller in _pointsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAnswers() async {
    try {
      final data = await ApiService.getSubmissionDetail(widget.submission['id']);
      setState(() {
        _answers = data['answers'] ?? [];
        _isLoading = false;
      });
      
      for (var answer in _answers) {
        final points = answer['pointsEarned'] ?? 0;
        _pointsControllers[answer['id']] = TextEditingController(text: points.toString());
      }
    } catch (e) {
      print('Error loading answers: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로드 실패: $e'),
            backgroundColor: const Color(0xFFCC0000),
          ),
        );
      }
    }
  }

  Future<void> _updateGrade(String answerId, bool isCorrect, int score) async {
    try {
      final success = await ApiService.gradeAnswer(answerId, isCorrect, score);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채점 완료', style: TextStyle(fontFamily: 'JoseonGulim')),
            backgroundColor: Color(0xFF00CC00),
          ),
        );
        await _loadAnswers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('채점 실패: $e', style: const TextStyle(fontFamily: 'JoseonGulim')),
            backgroundColor: const Color(0xFFCC0000),
          ),
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
          : _answers.isEmpty
              ? const Center(
                  child: Text(
                    '채점할 답안이 없습니다',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _answers.length,
                  itemBuilder: (context, index) {
                    return _buildAnswerCard(_answers[index], index + 1);
                  },
                ),
    );
  }

  Widget _buildAnswerCard(dynamic answer, int questionNumber) {
    final questionText = answer['questionText'] ?? '문제 없음';
    final studentAnswer = answer['studentAnswer'] ?? '';
    final correctAnswer = answer['correctAnswer'] ?? '';
    final answerId = answer['id'];
    final isCorrect = answer['isCorrect'] ?? false;
    final controller = _pointsControllers[answerId];

    return Card(
      color: const Color(0xFF595048),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '문제 $questionNumber',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCorrect)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00CC00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✓ 정답',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'JoseonGulim',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC0000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✗ 오답',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'JoseonGulim',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
                  Row(
                    children: [
                      const Text(
                        '학생 답안: ',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          studentAnswer,
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '정답: ',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          correctAnswer,
                          style: const TextStyle(
                            color: Color(0xFF00CC00),
                            fontFamily: 'JoseonGulim',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
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
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final points = int.tryParse(controller?.text ?? '0') ?? 0;
                    _updateGrade(answerId, true, points);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CC00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('정답', style: TextStyle(fontFamily: 'JoseonGulim')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateGrade(answerId, false, 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
