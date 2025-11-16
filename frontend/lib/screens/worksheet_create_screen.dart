import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WorksheetCreateScreen extends StatefulWidget {
  const WorksheetCreateScreen({super.key});

  @override
  State<WorksheetCreateScreen> createState() => _WorksheetCreateScreenState();
}

class _WorksheetCreateScreenState extends State<WorksheetCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  Future<void> _saveWorksheet() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ApiService.createWorksheet(
        _titleController.text,
        _descriptionController.text,
        _categoryController.text,
        _confirmedQuestions,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문제지가 생성되었습니다!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) {
        String questionText = '';
        String questionType = 'subjective';
        String optionA = '';
        String optionB = '';
        String optionC = '';
        String optionD = '';
        String correctAnswer = '';
        int points = 10;
        
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: const Text(
              '문제 추가',
              style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: questionType,
                    dropdownColor: const Color(0xFF595048),
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '문제 유형',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'subjective', child: Text('주관식')),
                      DropdownMenuItem(value: 'multiple_choice', child: Text('객관식')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        questionType = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => questionText = val,
                    maxLines: 3,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '문제',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                  if (questionType == 'multiple_choice') ...[
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (val) => optionA = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '① 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) => optionB = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '② 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) => optionC = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '③ 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) => optionD = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '④ 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => correctAnswer = val,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: InputDecoration(
                      labelText: questionType == 'multiple_choice' ? '정답 (A/B/C/D)' : '정답',
                      labelStyle: const TextStyle(color: Color(0xFF736A63)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => points = int.tryParse(val) ?? 10,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '배점',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
              ),
              TextButton(
                onPressed: () {
                  if (questionText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('문제를 입력하세요')),
                    );
                    return;
                  }
                  
                  setState(() {
                    _questions.add({
                      'questionNumber': _questions.length + 1,
                      'questionType': questionType,
                      'questionText': questionText,
                      'optionA': questionType == 'multiple_choice' ? optionA : null,
                      'optionB': questionType == 'multiple_choice' ? optionB : null,
                      'optionC': questionType == 'multiple_choice' ? optionC : null,
                      'optionD': questionType == 'multiple_choice' ? optionD : null,
                      'correctAnswer': correctAnswer,
                      'points': points,
                    });
                  });
                  Navigator.pop(context);
                },
                child: const Text('추가', style: TextStyle(color: Color(0xFFD9D4D2))),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editQuestion(int index) {
    final question = _questions[index];
    
    showDialog(
      context: context,
      builder: (context) {
        String questionText = question['questionText'] ?? '';
        String questionType = question['questionType'] ?? 'subjective';
        String optionA = question['optionA'] ?? '';
        String optionB = question['optionB'] ?? '';
        String optionC = question['optionC'] ?? '';
        String optionD = question['optionD'] ?? '';
        String correctAnswer = question['correctAnswer'] ?? '';
        int points = question['points'] ?? 10;
        
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: Text(
              '${question['questionNumber']}번 문제 수정',
              style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: questionType,
                    dropdownColor: const Color(0xFF595048),
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '문제 유형',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'subjective', child: Text('주관식')),
                      DropdownMenuItem(value: 'multiple_choice', child: Text('객관식')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        questionType = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: questionText),
                    onChanged: (val) => questionText = val,
                    maxLines: 3,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '문제',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                  if (questionType == 'multiple_choice') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: optionA),
                      onChanged: (val) => optionA = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '① 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: optionB),
                      onChanged: (val) => optionB = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '② 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: optionC),
                      onChanged: (val) => optionC = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '③ 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: optionD),
                      onChanged: (val) => optionD = val,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '④ 보기',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: correctAnswer),
                    onChanged: (val) => correctAnswer = val,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: InputDecoration(
                      labelText: questionType == 'multiple_choice' ? '정답 (A/B/C/D)' : '정답',
                      labelStyle: const TextStyle(color: Color(0xFF736A63)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: points.toString()),
                    onChanged: (val) => points = int.tryParse(val) ?? 10,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '배점',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _questions[index] = {
                      'questionNumber': question['questionNumber'],
                      'questionType': questionType,
                      'questionText': questionText,
                      'optionA': questionType == 'multiple_choice' ? optionA : null,
                      'optionB': questionType == 'multiple_choice' ? optionB : null,
                      'optionC': questionType == 'multiple_choice' ? optionC : null,
                      'optionD': questionType == 'multiple_choice' ? optionD : null,
                      'correctAnswer': correctAnswer,
                      'points': points,
                    };
                  });
                  Navigator.pop(context);
                },
                child: const Text('저장', style: TextStyle(color: Color(0xFFD9D4D2))),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      for (int i = 0; i < _questions.length; i++) {
        _questions[i]['questionNumber'] = i + 1;
      }
    });
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final questionNumber = question['questionNumber'] ?? (index + 1);
    final questionType = question['questionType'] ?? 'subjective';
    final questionText = question['questionText'] ?? '';
    final isMultipleChoice = questionType == 'multiple_choice';
    final hasCorrectAnswer = (question['correctAnswer'] ?? '').isNotEmpty;
    
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
                      fontSize: 12,
                    ),
                  ),
                ),
                if (!hasCorrectAnswer)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '정답 미입력',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFD9D4D2), size: 20),
                  onPressed: () => _editQuestion(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteQuestion(index),
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
            if (isMultipleChoice) ...[
              const SizedBox(height: 12),
              if (question['optionA'] != null)
                _buildOption('①', question['optionA']),
              if (question['optionB'] != null)
                _buildOption('②', question['optionB']),
              if (question['optionC'] != null)
                _buildOption('③', question['optionC']),
              if (question['optionD'] != null)
                _buildOption('④', question['optionD']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String marker, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$marker $text',
        style: const TextStyle(
          color: Color(0xFF736A63),
          fontFamily: 'JoseonGulim',
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '문제지 생성',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: [
          if (_questions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveWorksheet,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                decoration: const InputDecoration(
                  labelText: '문제지 제목',
                  labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF595048)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '설명',
                  labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF595048)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문제 목록 (${_questions.length}개)',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add, color: Color(0xFFD9D4D2)),
                    label: const Text(
                      '문제 추가',
                      style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF595048),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_questions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '문제를 추가하세요',
                      style: const TextStyle(
                        color: Color(0xFF736A63),
                        fontFamily: 'JoseonGulim',
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(
                  _questions.length,
                  (index) => _buildQuestionCard(_questions[index], index),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
