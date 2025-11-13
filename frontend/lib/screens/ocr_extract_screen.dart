import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<void> _pickAndExtract() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isProcessing = true;
        _fileName = result.files.single.name;
      });

      try {
        final response = await ApiService.extractQuestionsFromPdf(
          result.files.single.path!,
        );

        setState(() {
          _extractedQuestions = response['questions'] ?? [];
          _isProcessing = false;
        });

        if (_extractedQuestions.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('문제를 찾을 수 없습니다')),
            );
          }
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
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFD9D4D2)),
                  const SizedBox(height: 16),
                  Text(
                    'PDF에서 문제 추출 중...',
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
