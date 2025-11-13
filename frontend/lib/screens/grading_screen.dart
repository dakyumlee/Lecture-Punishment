import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GradingScreen extends StatefulWidget {
  const GradingScreen({super.key});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  List<dynamic> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoading = true);
    try {
      final submissions = await ApiService.getAllSubmissions();
      setState(() {
        _submissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _openGradingDetail(String submissionId) async {
    try {
      final detail = await ApiService.getSubmissionDetail(submissionId);
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradingDetailScreen(submission: detail),
          ),
        );
        _loadSubmissions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
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
          '제출 답안 채점',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
            )
          : _submissions.isEmpty
              ? const Center(
                  child: Text(
                    '제출된 답안이 없습니다',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSubmissions,
                  color: const Color(0xFFD9D4D2),
                  backgroundColor: const Color(0xFF595048),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _submissions.length,
                    itemBuilder: (context, index) {
                      final submission = _submissions[index];
                      return _buildSubmissionCard(submission);
                    },
                  ),
                ),
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    final studentName = submission['studentName'] ?? '';
    final worksheetTitle = submission['worksheetTitle'] ?? '';
    final totalScore = submission['totalScore'] ?? 0;
    final maxScore = submission['maxScore'] ?? 0;
    final submissionId = submission['id'] ?? '';
    final percentage = maxScore > 0 ? (totalScore * 100 / maxScore).toStringAsFixed(1) : '0.0';

    return Card(
      color: const Color(0xFF0D0D0D),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF595048)),
      ),
      child: InkWell(
        onTap: () => _openGradingDetail(submissionId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          worksheetTitle,
                          style: const TextStyle(
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalScore / $maxScore',
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF736A63), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    submission['submittedAt']?.toString().substring(0, 19) ?? '',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFF736A63), size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> submission;

  const GradingDetailScreen({super.key, required this.submission});

  @override
  State<GradingDetailScreen> createState() => _GradingDetailScreenState();
}

class _GradingDetailScreenState extends State<GradingDetailScreen> {
  late List<dynamic> _answers;
  Map<String, int> _pointsControllers = {};

  @override
  void initState() {
    super.initState();
    _answers = widget.submission['answers'] ?? [];
    for (var answer in _answers) {
      _pointsControllers[answer['id']] = answer['pointsEarned'] ?? 0;
    }
  }

  Future<void> _updateGrade(String answerId, int points, bool isCorrect) async {
    try {
      final success = await ApiService.gradeAnswer(
        answerId: answerId,
        pointsEarned: points,
        isCorrect: isCorrect,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채점이 저장되었습니다')),
        );
        Navigator.pop(context);
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
    final studentName = widget.submission['studentName'] ?? '';
    final worksheetTitle = widget.submission['worksheetTitle'] ?? '';
    final totalScore = widget.submission['totalScore'] ?? 0;
    final maxScore = widget.submission['maxScore'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: Text(
          '$studentName - $worksheetTitle',
          style: const TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF595048),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총점',
                  style: TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$totalScore / $maxScore',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _answers.length,
              itemBuilder: (context, index) {
                final answer = _answers[index];
                return _buildAnswerCard(answer);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(dynamic answer) {
    final questionNumber = answer['questionNumber'] ?? 0;
    final questionText = answer['questionText'] ?? '';
    final correctAnswer = answer['correctAnswer'] ?? '';
    final studentAnswer = answer['studentAnswer'] ?? '';
    final isCorrect = answer['isCorrect'] ?? false;
    final pointsEarned = answer['pointsEarned'] ?? 0;
    final maxPoints = answer['maxPoints'] ?? 0;
    final answerId = answer['id'] ?? '';
    final questionType = answer['questionType'] ?? 'subjective';

    return Card(
      color: const Color(0xFF595048),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00010D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$questionNumber번',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$pointsEarned / $maxPoints점',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              questionText,
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00010D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '정답',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correctAnswer,
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '학생 답안',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentAnswer,
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (questionType == 'subjective') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '부여 점수',
                          style: TextStyle(
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _pointsControllers[answerId]?.toDouble() ?? 0,
                          min: 0,
                          max: maxPoints.toDouble(),
                          divisions: maxPoints,
                          activeColor: const Color(0xFFD9D4D2),
                          inactiveColor: const Color(0xFF736A63),
                          label: '${_pointsControllers[answerId] ?? 0}점',
                          onChanged: (value) {
                            setState(() {
                              _pointsControllers[answerId] = value.toInt();
                            });
                          },
                        ),
                        Text(
                          '${_pointsControllers[answerId] ?? 0} / $maxPoints점',
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final points = _pointsControllers[answerId] ?? 0;
                      final correct = points == maxPoints;
                      _updateGrade(answerId, points, correct);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D4D2),
                      foregroundColor: const Color(0xFF00010D),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontFamily: 'JoseonGulim',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
