import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'ocr_extract_screen.dart';
import '../config/env.dart';
import 'question_add_screen.dart';
import 'worksheet_create_screen.dart';
import 'worksheet_solve_screen.dart';

class WorksheetManageScreen extends StatefulWidget {
  const WorksheetManageScreen({super.key});
  @override
  State<WorksheetManageScreen> createState() => _WorksheetManageScreenState();
}

class _WorksheetManageScreenState extends State<WorksheetManageScreen> {
  List<dynamic> _worksheets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    setState(() => _isLoading = true);
    try {
      final worksheets = await ApiService.getAllWorksheets();
      setState(() {
        _worksheets = worksheets;
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

  Future<void> _deleteWorksheet(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '삭제 확인',
          style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        ),
        content: Text(
          '$title 문제지를 삭제하시겠습니까?\n모든 문제가 함께 삭제됩니다.',
          style: const TextStyle(color: Color(0xFFD9D4D2)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await ApiService.deleteWorksheet(id);
        if (success) {
          _loadWorksheets();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('문제지가 삭제되었습니다')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('삭제 실패')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  void _viewWorksheet(String id, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorksheetSolveScreen(
          worksheetId: id,
          worksheetTitle: title,
          studentId: 'preview',
        ),
      ),
    );
  }

  void _downloadPdf(String id, String title) {
    final url = '${Env.apiUrl}/worksheets/$id/download';
    html.AnchorElement(href: url)
      ..setAttribute('download', '$title.txt')
      ..click();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('문제지 다운로드 시작')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '문제지 관리',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OcrExtractScreen(),
                ),
              );
            },
            tooltip: 'OCR 문제 추출',
          ),
        ],
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorksheetCreateScreen(),
            ),
          );
          if (result == true) {
            _loadWorksheets();
          }
        },
        backgroundColor: const Color(0xFF595048),
        icon: const Icon(Icons.add, color: Color(0xFFD9D4D2)),
        label: const Text(
          '문제지 생성',
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
            )
          : _worksheets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Color(0xFF595048),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '문제지가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '아래 + 버튼으로 새로운 문제지를 생성하세요',
                        style: TextStyle(
                          color: Color(0xFF595048),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWorksheets,
                  color: const Color(0xFFD9D4D2),
                  backgroundColor: const Color(0xFF595048),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _worksheets.length,
                    itemBuilder: (context, index) {
                      final worksheet = _worksheets[index];
                      return _buildWorksheetCard(worksheet);
                    },
                  ),
                ),
    );
  }

  Widget _buildWorksheetCard(dynamic worksheet) {
    final title = worksheet['title'] ?? '제목 없음';
    final category = worksheet['category'] ?? '미분류';
    final description = worksheet['description'] ?? '';
    final totalQuestions = worksheet['questionCount'] ?? 0;
    final id = worksheet['id'] ?? '';

    return Card(
      color: const Color(0xFF0D0D0D),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF595048)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF595048),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.quiz, color: Color(0xFF736A63), size: 16),
              const SizedBox(width: 4),
              Text(
                '$totalQuestions개',
                style: const TextStyle(
                  color: Color(0xFF736A63),
                  fontFamily: 'JoseonGulim',
                ),
              ),
            ],
          ),
        ),
        iconColor: const Color(0xFFD9D4D2),
        collapsedIconColor: const Color(0xFF736A63),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (description.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00010D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF736A63),
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionAddScreen(
                                worksheetId: id,
                                worksheetTitle: title,
                              ),
                            ),
                          ).then((_) => _loadWorksheets());
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('문제 추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewWorksheet(id, title),
                        icon: const Icon(Icons.visibility, size: 20),
                        label: const Text('보기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF736A63),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(id, title),
                        icon: const Icon(Icons.download, size: 20),
                        label: const Text('다운로드'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048).withOpacity(0.7),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteWorksheet(id, title),
                        icon: const Icon(Icons.delete, size: 20),
                        label: const Text('삭제'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
