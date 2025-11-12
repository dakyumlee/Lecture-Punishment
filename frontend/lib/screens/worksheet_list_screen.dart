import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'worksheet_solve_screen.dart';

class WorksheetListScreen extends StatefulWidget {
  final String studentId;
  
  const WorksheetListScreen({super.key, required this.studentId});

  @override
  State<WorksheetListScreen> createState() => _WorksheetListScreenState();
}

class _WorksheetListScreenState extends State<WorksheetListScreen> {
  List<dynamic> _worksheets = [];
  String? _selectedCategory;
  bool _isLoading = true;

  final List<String> _categories = ['전체', '프로그래밍', '자료구조', '데이터베이스', '네트워크', '운영체제'];

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    setState(() => _isLoading = true);
    
    try {
      final url = _selectedCategory == null || _selectedCategory == '전체'
          ? 'http://localhost:8080/api/worksheets'
          : 'http://localhost:8080/api/worksheets/category/$_selectedCategory';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        setState(() {
          _worksheets = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('문제지 목록', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat || (_selectedCategory == null && cat == '전체');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(
                      fontFamily: 'JoseonGulim',
                      color: isSelected ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
                    )),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD9D4D2),
                    backgroundColor: const Color(0xFF595048),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat == '전체' ? null : cat);
                      _loadWorksheets();
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
                : _worksheets.isEmpty
                    ? const Center(child: Text('문제지가 없습니다', 
                        style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim', fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _worksheets.length,
                        itemBuilder: (context, index) {
                          final worksheet = _worksheets[index];
                          return Card(
                            color: const Color(0xFF595048),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                worksheet['title'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFFD9D4D2),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${worksheet['subject']} | ${worksheet['category']}',
                                    style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                                  ),
                                  Text(
                                    '난이도: ${'⭐' * (worksheet['difficultyLevel'] ?? 1)}',
                                    style: const TextStyle(color: Color(0xFF736A63)),
                                  ),
                                  Text(
                                    '문제 수: ${worksheet['totalQuestions'] ?? 0}',
                                    style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD9D4D2), size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorksheetSolveScreen(
                                      worksheetId: worksheet['id'],
                                      worksheetTitle: worksheet['title'],
                                      studentId: widget.studentId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
