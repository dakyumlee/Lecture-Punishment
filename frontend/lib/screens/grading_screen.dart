import '../services/api_service.dart';
import 'package:flutter/material.dart';

class GradingScreen extends StatefulWidget {
  const GradingScreen({super.key});
  @override
  State<GradingScreen> createState() => _GradingScreenState();
}
class _GradingScreenState extends State<GradingScreen> {
  List<dynamic> _submissions = [];
  bool _isLoading = true;
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
  Future<void> _openGradingDetail(String submissionId) async {
      final detail = await ApiService.getSubmissionDetail(submissionId);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradingDetailScreen(submission: detail),
          ),
        _loadSubmissions();
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '채점',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _submissions.isEmpty
              ? const Center(
                  child: Text(
                    '제출된 과제가 없습니다',
                    style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _submissions.length,
                  itemBuilder: (context, index) {
                    final submission = _submissions[index];
                    return Card(
                      color: const Color(0xFF595048),
                      child: ListTile(
                        title: Text(
                          submission['studentName'] ?? '학생',
                          style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                        ),
                        subtitle: Text(
                          submission['worksheetTitle'] ?? '',
                          style: const TextStyle(color: Color(0xFF736A63)),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFFD9D4D2)),
                        onTap: () => _openGradingDetail(submission['id']),
                      ),
                    );
                  },
                ),
    );
class GradingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> submission;
  const GradingDetailScreen({super.key, required this.submission});
  State<GradingDetailScreen> createState() => _GradingDetailScreenState();
class _GradingDetailScreenState extends State<GradingDetailScreen> {
  late List<dynamic> _answers;
  Map<String, int> _pointsControllers = {};
    _answers = widget.submission['answers'] ?? [];
    for (var answer in _answers) {
      _pointsControllers[answer['id']] = answer['pointsEarned'] ?? 0;
  Future<void> _updateGrade(String answerId, int points, bool isCorrect) async {
      final success = await ApiService.gradeAnswer(
        submissionId: widget.submission['id'],
        answerId: answerId,
        isCorrect: isCorrect,
        score: points,
      );
      
      if (success && mounted) {
          const SnackBar(content: Text('채점이 저장되었습니다')),
        Navigator.pop(context);
          SnackBar(content: Text('채점 실패: $e')),
        title: Text(
          '${widget.submission['studentName']} - 채점',
          style: const TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _answers.length,
        itemBuilder: (context, index) {
          final answer = _answers[index];
          final answerId = answer['id'];
          final questionText = answer['questionText'] ?? '';
          final studentAnswer = answer['answer'] ?? '';
          final maxPoints = answer['maxPoints'] ?? 10;
          return Card(
            color: const Color(0xFF595048),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '문제 ${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  const SizedBox(height: 8),
                    questionText,
                    style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(8),
                    child: Text(
                      '학생 답안: $studentAnswer',
                      style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        '점수:',
                        style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          style: const TextStyle(color: Color(0xFFD9D4D2)),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: const TextStyle(color: Color(0xFF736A63)),
                            filled: true,
                            fillColor: const Color(0xFF0D0D0D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onChanged: (value) {
                            _pointsControllers[answerId] = int.tryParse(value) ?? 0;
                          },
                      Text(
                        ' / $maxPoints',
                        style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
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
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            fontFamily: 'JoseonGulim',
                            fontWeight: FontWeight.bold,
                    ],
                ],
              ),
            ),
          );
        },
