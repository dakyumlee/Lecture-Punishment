import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env.dart';
import '../services/api_service.dart';

class OcrExtractScreen extends StatefulWidget {
  const OcrExtractScreen({super.key});

  @override
  State<OcrExtractScreen> createState() => _OcrExtractScreenState();
}

class _OcrExtractScreenState extends State<OcrExtractScreen> {
  bool _isProcessing = false;
  List<dynamic> _extractedQuestions = [];
  String? _fileName;
  List<bool> _selectedQuestions = [];

  Future<void> _pickAndExtract() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isProcessing = true;
        _fileName = result.files.single.name;
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
          final data = jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<void> _addToWorksheet() async {
    try {
      final worksheets = await ApiService.getWorksheets();
      
      if (worksheets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문제지가 없습니다. 먼저 문제지를 생성하세요.')),
        );
        return;
      }

      if (!mounted) return;
      
      final selectedWorksheet = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF595048),
          title: const Text(
            '문제지 선택',
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: worksheets.length,
              itemBuilder: (context, index) {
                final worksheet = worksheets[index];
                return ListTile(
                  title: Text(
                    worksheet['title'],
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                  ),
                  subtitle: Text(
                    '${worksheet['description'] ?? ''}',
                    style: const TextStyle(color: Color(0xFF736A63)),
                  ),
                  onTap: () => Navigator.pop(context, worksheet['id']),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
            ),
          ],
        ),
      );

      if (selectedWorksheet != null && mounted) {
        setState(() => _isProcessing = true);
        
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
              'correctAnswer': '',
              'points': 10,
            };
            
            final success = await ApiService.addQuestionToWorksheet(
              selectedWorksheet,
              questionData,
            );
            
            if (success) addedCount++;
          }
        }
        
        setState(() => _isProcessing = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$addedCount개 문제를 추가했습니다!')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추가 실패: $e')),
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
          'OCR 문제 추출',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: _extractedQuestions.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addToWorksheet,
                  tooltip: '문제지에 추가',
                ),
              ]
            : null,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFD9D4D2)),
                  const SizedBox(height: 16),
                  Text(
                    _extractedQuestions.isEmpty ? 'PDF에서 문제 추출 중...' : '문제 추가 중...',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                    ),
                  ),
                  if (_fileName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _fileName!,
                      style: const TextStyle(
                        color: Color(0xFF595048),
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : _extractedQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.document_scanner,
                        size: 80,
                        color: Color(0xFF595048),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'PDF 파일을 업로드하여\n문제를 자동으로 추출하세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _pickAndExtract,
                        icon: const Icon(Icons.upload_file),
                        label: const Text(
                          'PDF 업로드',
                          style: TextStyle(
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D4D2),
                          foregroundColor: const Color(0xFF00010D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
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
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _addToWorksheet,
                                icon: const Icon(Icons.add_circle, size: 18),
                                label: const Text('문제지에 추가'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD9D4D2),
                                  foregroundColor: const Color(0xFF00010D),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _pickAndExtract,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('다시 추출'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF736A63),
                                  foregroundColor: const Color(0xFFD9D4D2),
                                ),
                              ),
                            ],
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
                ),
    );
  }

  Widget _buildQuestionCard(dynamic question, int index) {
    final questionNumber = question['questionNumber'] ?? (index + 1);
    final questionType = question['questionType'] ?? 'subjective';
    final questionText = question['questionText'] ?? '';
    final isMultipleChoice = questionType == 'multiple_choice';

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
}
