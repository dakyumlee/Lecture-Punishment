import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env.dart';
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
  final _categoryController = TextEditingController();
  
  bool _isProcessing = false;
  List<dynamic> _extractedQuestions = [];
  String? _fileName;
  List<bool> _selectedQuestions = [];
  String? _createdWorksheetId;
  List<int>? _pdfBytes;

  Future<void> _pickAndExtract() async {
    if (!_formKey.currentState!.validate()) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isProcessing = true;
        _fileName = result.files.single.name;
        _pdfBytes = result.files.single.bytes!;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Env.apiUrl}/ocr/extract'),
        );
        
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          result.files.single.bytes!,
          filename: result.files.single.name,
        ));
        
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _extractedQuestions = data['questions'] ?? [];
            _selectedQuestions = List.filled(_extractedQuestions.length, true);
            _isProcessing = false;
          });

          if (_extractedQuestions.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('문제를 찾을 수 없습니다')),
              );
            }
          }
        } else {
          throw Exception('OCR 실패: ${response.statusCode}');
        }
      } catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OCR 실패: $e')),
          );
        }
      }
    }
  }

  Future<void> _createWorksheetAndAddQuestions() async {
    bool hasUnanswered = false;
    for (int i = 0; i < _extractedQuestions.length; i++) {
      if (_selectedQuestions[i]) {
        final q = _extractedQuestions[i];
        if (q['correctAnswer'] == null || q['correctAnswer'].toString().trim().isEmpty) {
          hasUnanswered = true;
          break;
        }
      }
    }

    if (hasUnanswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택된 모든 문제의 정답을 입력하세요!')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final worksheetData = await ApiService.uploadPdfWorksheet(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        fileBytes: _pdfBytes!,
        fileName: _fileName!,
      );

      _createdWorksheetId = worksheetData['id'];

      int addedCount = 0;
      for (int i = 0; i < _extractedQuestions.length; i++) {
        if (_selectedQuestions[i]) {
          final question = _extractedQuestions[i];
          
          final questionData = {
            'questionNumber': question['questionNumber'],
            'questionType': question['questionType'],
            'questionText': question['questionText'],
            'optionA': question['optionA'],
            'optionB': question['optionB'],
            'optionC': question['optionC'],
            'optionD': question['optionD'],
            'correctAnswer': question['correctAnswer'],
            'points': question['points'] ?? 10,
            'allowPartial': question['questionType'] == 'subjective',
            'similarityThreshold': question['similarityThreshold'] ?? 0.85,
          };
          
          final success = await ApiService.addQuestionToWorksheet(
            _createdWorksheetId!,
            questionData,
          );
          
          if (success) addedCount++;
        }
      }
      
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제지 생성 완료! $addedCount개 문제 추가됨')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: $e')),
        );
      }
    }
  }

  Future<void> _editQuestion(int index) async {
    final question = _extractedQuestions[index];
    final isMultipleChoice = question['questionType'] == 'multiple_choice';
    
    final questionTextController = TextEditingController(text: question['questionText']);
    final optionAController = TextEditingController(text: question['optionA'] ?? '');
    final optionBController = TextEditingController(text: question['optionB'] ?? '');
    final optionCController = TextEditingController(text: question['optionC'] ?? '');
    final optionDController = TextEditingController(text: question['optionD'] ?? '');
    final correctAnswerController = TextEditingController(text: question['correctAnswer'] ?? '');
    final thresholdController = TextEditingController(
      text: (question['similarityThreshold'] ?? 0.85).toString()
    );
    
    String correctAnswer = question['correctAnswer'] ?? '';
    bool isObjective = isMultipleChoice;
    double threshold = question['similarityThreshold'] ?? 0.85;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
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
                Row(
                  children: [
                    const Text('문제 유형:', style: TextStyle(color: Color(0xFFD9D4D2))),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('주관식'),
                      selected: !isObjective,
                      onSelected: (selected) {
                        setDialogState(() {
                          isObjective = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('객관식'),
                      selected: isObjective,
                      onSelected: (selected) {
                        setDialogState(() {
                          isObjective = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: questionTextController,
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
                if (isObjective) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: optionAController,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '① 보기',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optionBController,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '② 보기',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optionCController,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '③ 보기',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optionDController,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '④ 보기',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF736A63)),
                const SizedBox(height: 8),
                const Text(
                  '정답 설정',
                  style: TextStyle(color: Color(0xFFD9D4D2), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (isObjective) ...[
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('①'),
                        selected: correctAnswer == 'A',
                        onSelected: (selected) {
                          setDialogState(() {
                            correctAnswer = 'A';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('②'),
                        selected: correctAnswer == 'B',
                        onSelected: (selected) {
                          setDialogState(() {
                            correctAnswer = 'B';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('③'),
                        selected: correctAnswer == 'C',
                        onSelected: (selected) {
                          setDialogState(() {
                            correctAnswer = 'C';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('④'),
                        selected: correctAnswer == 'D',
                        onSelected: (selected) {
                          setDialogState(() {
                            correctAnswer = 'D';
                          });
                        },
                      ),
                    ],
                  ),
                ] else ...[
                  TextField(
                    controller: correctAnswerController,
                    onChanged: (value) {
                      correctAnswer = value;
                    },
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '정답 입력',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      threshold = double.tryParse(value) ?? 0.85;
                    },
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                    decoration: const InputDecoration(
                      labelText: '유사도 임계값 (0.0 ~ 1.0)',
                      helperText: '정답과 비교 시 허용 오차 (0.85 권장)',
                      helperStyle: TextStyle(color: Color(0xFF736A63), fontSize: 12),
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _extractedQuestions[index] = {
                    'questionNumber': question['questionNumber'],
                    'questionType': isObjective ? 'multiple_choice' : 'subjective',
                    'questionText': questionTextController.text,
                    'optionA': isObjective ? optionAController.text : null,
                    'optionB': isObjective ? optionBController.text : null,
                    'optionC': isObjective ? optionCController.text : null,
                    'optionD': isObjective ? optionDController.text : null,
                    'correctAnswer': correctAnswer,
                    'similarityThreshold': isObjective ? null : threshold,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text('저장', style: TextStyle(color: Color(0xFFD9D4D2))),
            ),
          ],
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
          'PDF 문제지 생성',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFD9D4D2)),
                  const SizedBox(height: 16),
                  Text(
                    _extractedQuestions.isEmpty ? 'OCR 처리 중...' : '문제지 생성 중...',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _extractedQuestions.isEmpty
              ? _buildInitialForm()
              : _buildQuestionList(),
    );
  }

  Widget _buildInitialForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              decoration: InputDecoration(
                labelText: '문제지 제목',
                labelStyle: const TextStyle(color: Color(0xFF736A63)),
                filled: true,
                fillColor: const Color(0xFF0D0D0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF595048)),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? '제목을 입력하세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '설명',
                labelStyle: const TextStyle(color: Color(0xFF736A63)),
                filled: true,
                fillColor: const Color(0xFF0D0D0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF595048)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              decoration: InputDecoration(
                labelText: '카테고리',
                hintText: '예: HTML/CSS, JavaScript, React',
                hintStyle: const TextStyle(color: Color(0xFF736A63)),
                labelStyle: const TextStyle(color: Color(0xFF736A63)),
                filled: true,
                fillColor: const Color(0xFF0D0D0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF595048)),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? '카테고리를 입력하세요' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickAndExtract,
              icon: const Icon(Icons.upload_file, size: 24),
              label: const Text(
                'PDF 업로드 및 OCR 추출',
                style: TextStyle(fontSize: 18, fontFamily: 'JoseonGulim'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF595048),
                foregroundColor: const Color(0xFFD9D4D2),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF595048),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '추출된 문제: ${_extractedQuestions.length}개',
                style: const TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createWorksheetAndAddQuestions,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('문제지 생성'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9D4D2),
                  foregroundColor: const Color(0xFF00010D),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _extractedQuestions.length,
            itemBuilder: (context, index) {
              final question = _extractedQuestions[index];
              return _buildQuestionCard(question, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(dynamic question, int index) {
    final questionNumber = question['questionNumber'] ?? (index + 1);
    final questionType = question['questionType'] ?? 'subjective';
    final questionText = question['questionText'] ?? '';
    final isMultipleChoice = questionType == 'multiple_choice';
    final hasCorrectAnswer = question['correctAnswer'] != null && 
                            question['correctAnswer'].toString().trim().isNotEmpty;

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
                Checkbox(
                  value: _selectedQuestions[index],
                  onChanged: (value) {
                    setState(() {
                      _selectedQuestions[index] = value ?? false;
                    });
                  },
                  fillColor: WidgetStateProperty.all(const Color(0xFFD9D4D2)),
                  checkColor: const Color(0xFF00010D),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                if (!hasCorrectAnswer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '정답 미입력',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'JoseonGulim',
                        fontSize: 11,
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFD9D4D2), size: 20),
                  onPressed: () => _editQuestion(index),
                  tooltip: '문제 수정',
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
            if (hasCorrectAnswer) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF736A63)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '정답: ${question['correctAnswer']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'JoseonGulim',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
