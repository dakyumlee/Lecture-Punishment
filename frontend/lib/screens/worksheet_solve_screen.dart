import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'worksheet_result_screen.dart';

class WorksheetSolveScreen extends StatefulWidget {
  final String worksheetId;
  final String worksheetTitle;
  final String studentId;

  const WorksheetSolveScreen({
    super.key,
    required this.worksheetId,
    required this.worksheetTitle,
    required this.studentId,
  });

  @override
  State<WorksheetSolveScreen> createState() => _WorksheetSolveScreenState();
}

class _WorksheetSolveScreenState extends State<WorksheetSolveScreen> {
  Map<String, dynamic>? _worksheet;
  List<dynamic> _questions = [];
  Map<String, TextEditingController> _answerControllers = {};
  Map<String, String?> _selectedAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadWorksheet();
  }

  Future<void> _loadWorksheet() async {
    try {
      final data = await ApiService.getWorksheetWithQuestions(widget.worksheetId);
      
      setState(() {
        _worksheet = data['worksheet'];
        _questions = data['questions'];
        for (var q in _questions) {
          _answerControllers[q['id']] = TextEditingController();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  Future<void> _submitAnswers() async {
    bool allAnswered = true;
    for (var q in _questions) {
      final questionId = q['id'];
      if (q['questionType'] == 'multiple_choice') {
        if (_selectedAnswers[questionId] == null) {
          allAnswered = false;
          break;
        }
      } else {
        if (_answerControllers[questionId]?.text.isEmpty ?? true) {
          allAnswered = false;
          break;
        }
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 문제에 답을 입력해주세요!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final answers = _questions.map((q) {
        final questionId = q['id'];
        final answer = q['questionType'] == 'multiple_choice'
            ? _selectedAnswers[questionId]
            : _answerControllers[questionId]?.text;
        return {'questionId': questionId, 'answer': answer ?? ''};
      }).toList();

      final result = await ApiService.submitWorksheet(
        worksheetId: widget.worksheetId,
        studentId: widget.studentId,
        answers: answers,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorksheetResultScreen(
              result: result,
              worksheetTitle: widget.worksheetTitle,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('제출 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: Text(widget.worksheetTitle, 
          style: const TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF595048),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _worksheet?['description'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '총 ${_questions.length}문제',
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      final questionId = question['id'];
                      final isMultipleChoice = question['questionType'] == 'multiple_choice';

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
                                      '${question['questionNumber']}번',
                                      style: const TextStyle(
                                        color: Color(0xFFD9D4D2),
                                        fontFamily: 'JoseonGulim',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isMultipleChoice ? const Color(0xFF736A63) : const Color(0xFFD9D4D2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isMultipleChoice ? '객관식' : '주관식',
                                      style: TextStyle(
                                        color: isMultipleChoice ? const Color(0xFFD9D4D2) : const Color(0xFF00010D),
                                        fontFamily: 'JoseonGulim',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${question['points']}점',
                                    style: const TextStyle(
                                      color: Color(0xFF736A63),
                                      fontFamily: 'JoseonGulim',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                question['questionText'],
                                style: const TextStyle(
                                  color: Color(0xFFD9D4D2),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (isMultipleChoice) ...[
                                _buildMultipleChoiceOption(questionId, 'A', question['optionA']),
                                _buildMultipleChoiceOption(questionId, 'B', question['optionB']),
                                _buildMultipleChoiceOption(questionId, 'C', question['optionC']),
                                _buildMultipleChoiceOption(questionId, 'D', question['optionD']),
                              ] else ...[
                                TextField(
                                  controller: _answerControllers[questionId],
                                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: '답을 입력하세요',
                                    hintStyle: TextStyle(color: Color(0xFF736A63)),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF736A63)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D4D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Color(0xFF00010D))
                        : const Text(
                            '제출하기',
                            style: TextStyle(
                              fontFamily: 'JoseonGulim',
                              fontSize: 18,
                              color: Color(0xFF00010D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMultipleChoiceOption(String questionId, String option, String text) {
    final isSelected = _selectedAnswers[questionId] == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedAnswers[questionId] = option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF00010D) : const Color(0xFF595048),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
