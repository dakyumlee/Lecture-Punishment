import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'worksheet_solve_screen.dart';

class WorksheetListScreen extends StatefulWidget {
  final String studentId;
  const WorksheetListScreen({super.key, required this.studentId});
  @override
  State<WorksheetListScreen> createState() => _WorksheetListScreenState();
}

class _WorksheetListScreenState extends State<WorksheetListScreen> {
  List<dynamic> _worksheets = [];
  Map<String, List<dynamic>> _groupedWorksheets = {};
  bool _isLoading = true;
  String _selectedCategory = '전체';

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    try {
      final data = await ApiService.getAllWorksheets();
      final grouped = <String, List<dynamic>>{};
      for (var ws in data) {
        final category = ws['category'] ?? '기타';
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(ws);
      }
      setState(() {
        _worksheets = data;
        _groupedWorksheets = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  List<dynamic> get _filteredWorksheets {
    if (_selectedCategory == '전체') {
      return _groupedWorksheets.values.expand((list) => list).toList();
    }
    return _groupedWorksheets[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('문제지 목록', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
                : _worksheets.isEmpty
                    ? const Center(
                        child: Text(
                          '문제지가 없습니다',
                          style: TextStyle(
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                            fontSize: 18,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWorksheets,
                        color: const Color(0xFFD9D4D2),
                        backgroundColor: const Color(0xFF595048),
                        child: _buildWorksheetList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: const Color(0xFF595048),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: ['전체', ..._groupedWorksheets.keys].length,
        itemBuilder: (context, index) {
          final category = index == 0 ? '전체' : _groupedWorksheets.keys.elementAt(index - 1);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => setState(() => _selectedCategory = category),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory == category ? const Color(0xFF0D0D0D) : const Color(0xFF736A63),
                foregroundColor: const Color(0xFFD9D4D2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  fontFamily: 'JoseonGulim',
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorksheetList() {
    final worksheets = _filteredWorksheets;
    if (worksheets.isEmpty) {
      return const Center(
        child: Text(
          '이 카테고리에 문제지가 없습니다',
          style: TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: worksheets.length,
      itemBuilder: (context, index) {
        return _buildWorksheetCard(worksheets[index]);
      },
    );
  }

  Widget _buildWorksheetCard(dynamic worksheet) {
    final title = worksheet['title'] ?? 'Untitled';
    final description = worksheet['description'] ?? '';
    final category = worksheet['category'] ?? '';
    final totalQuestions = worksheet['totalQuestions'] ?? 0;
    return Card(
      color: const Color(0xFF595048),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorksheetSolveScreen(
                worksheetId: worksheet['id'],
                worksheetTitle: title,
                studentId: widget.studentId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
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
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.quiz, color: Color(0xFF736A63), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '문제 $totalQuestions개',
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
        ),
      ),
    );
  }
}