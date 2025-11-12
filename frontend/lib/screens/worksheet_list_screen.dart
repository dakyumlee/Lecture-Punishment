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
  Map<String, List<dynamic>> _groupedWorksheets = {};
  List<String> _categories = ['전체'];
  String _selectedCategory = '전체';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await ApiService.getWorksheetsGrouped();
      
      setState(() {
        _groupedWorksheets = Map<String, List<dynamic>>.from(
          data.map((key, value) => 
            MapEntry(key.toString(), List<dynamic>.from(value))
          ),
        );
        
        _categories = ['전체', ..._groupedWorksheets.keys.toList()];
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
        backgroundColor: const Color(0xFF00010D),
        title: const Text(
          '문제지 목록',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD9D4D2),
                    ),
                  )
                : _filteredWorksheets.isEmpty
                    ? const Center(
                        child: Text(
                          '문제지가 없습니다',
                          style: TextStyle(
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWorksheets,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredWorksheets.length,
                          itemBuilder: (context, index) {
                            final worksheet = _filteredWorksheets[index];
                            return _buildWorksheetCard(worksheet);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() => _selectedCategory = category);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? const Color(0xFF595048)
                    : const Color(0xFF0D0D0D),
                foregroundColor: const Color(0xFFD9D4D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF736A63)
                        : const Color(0xFF595048),
                  ),
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
        border: Border.all(color: const Color(0xFF595048)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorksheetSolveScreen(
                worksheetId: id,
                studentId: widget.studentId,
              ),
            ),
          ).then((_) => _loadWorksheets());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                  const Icon(
                    Icons.quiz,
                    color: Color(0xFF736A63),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '문제 $totalQuestions개',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF595048),
                    size: 16,
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
