import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'question_add_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '문제지 목록',
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
          : _worksheets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '문제지가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '상단 메뉴에서 문제지를 생성하세요',
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
    final totalQuestions = worksheet['totalQuestions'] ?? 0;
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
              Text(
                '문제 $totalQuestions개',
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
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
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
                        icon: const Icon(Icons.add),
                        label: const Text('문제 추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 문제지 보기
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('보기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF736A63),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
