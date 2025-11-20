import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BuildMakerAdminScreen extends StatefulWidget {
  const BuildMakerAdminScreen({super.key});

  @override
  State<BuildMakerAdminScreen> createState() => _BuildMakerAdminScreenState();
}

class _BuildMakerAdminScreenState extends State<BuildMakerAdminScreen> {
  List<Map<String, dynamic>> _lectures = [];
  bool _isLoading = true;

  final _topicController = TextEditingController();
  final _syllabusController = TextEditingController();
  int _difficulty = 3;

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _syllabusController.dispose();
    super.dispose();
  }

  Future<void> _loadLectures() async {
    final lectures = await ApiService.getAILectures();
    setState(() {
      _lectures = lectures;
      _isLoading = false;
    });
  }

  Future<void> _generate() async {
    if (_topicController.text.isEmpty) return;
    
    await ApiService.generateAILecture(
      topic: _topicController.text,
      syllabus: _syllabusController.text,
      difficulty: _difficulty,
    );
    
    Navigator.pop(context);
    _topicController.clear();
    _syllabusController.clear();
    _loadLectures();
  }

  List<Map<String, String>> _parseScript(String script) {
    List<Map<String, String>> sections = [];
    
    final sectionPattern = RegExp(r'\[(.*?)\]\s*\n\n(.*?)(?=\n\n\[|$)', dotAll: true);
    final matches = sectionPattern.allMatches(script);
    
    for (var match in matches) {
      sections.add({
        'title': match.group(1) ?? '',
        'content': match.group(2)?.trim() ?? '',
      });
    }
    
    if (sections.isEmpty) {
      sections.add({
        'title': '강의 내용',
        'content': script,
      });
    }
    
    return sections;
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case '도입':
        return Icons.wb_sunny;
      case '핵심개념':
        return Icons.lightbulb;
      case '예제':
        return Icons.code;
      case '실습':
        return Icons.edit;
      case '심화':
        return Icons.trending_up;
      case '정리':
        return Icons.check_circle;
      default:
        return Icons.article;
    }
  }

  Color _getSectionColor(String title) {
    switch (title) {
      case '도입':
        return const Color(0xFFFF9800);
      case '핵심개념':
        return const Color(0xFFFFEB3B);
      case '예제':
        return const Color(0xFF2196F3);
      case '실습':
        return const Color(0xFF4CAF50);
      case '심화':
        return const Color(0xFF9C27B0);
      case '정리':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF736A63);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('🤖 AI 강의 관리', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lectures.length,
              itemBuilder: (context, i) {
                final lec = _lectures[i];
                return Card(
                  color: const Color(0xFF595048),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.auto_awesome, color: Color(0xFF4CAF50)),
                    title: Text(lec['lectureName'] ?? '', style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
                    subtitle: Text('난이도 ${lec['difficulty']} | ${lec['estimatedDuration']}분', style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Color(0xFFD9D4D2)),
                          onPressed: () => _showDetail(lec['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteLecture(lec['id'], lec['lectureName']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text('AI 강의 생성', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Color(0xFFD9D4D2)),
              decoration: const InputDecoration(
                labelText: '주제',
                labelStyle: TextStyle(color: Color(0xFF736A63)),
              ),
            ),
            TextField(
              controller: _syllabusController,
              style: const TextStyle(color: Color(0xFFD9D4D2)),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '강의 계획',
                labelStyle: TextStyle(color: Color(0xFF736A63)),
              ),
            ),
            Slider(
              value: _difficulty.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_difficulty',
              onChanged: (v) => setState(() => _difficulty = v.toInt()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Color(0xFF736A63)))),
          ElevatedButton(
            onPressed: _generate,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('생성', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetail(int id) async {
    final detail = await ApiService.getAILectureDetail(id);
    if (!mounted) return;
    
    final scrollController = ScrollController();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF00010D),
          appBar: AppBar(
            title: Text(
              detail['lectureName'] ?? '강의',
              style: const TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
            ),
            backgroundColor: const Color(0xFF595048),
            iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF595048),
                      title: const Text('삭제 확인', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
                      content: Text(
                        '${detail['lectureName']} 강의를 삭제하시겠습니까?',
                        style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
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
                    final success = await ApiService.deleteAILecture(id);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '강의가 삭제되었습니다' : '삭제 실패'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                      if (success) _loadLectures();
                    }
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF595048),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Color(0xFFFFD700), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail['topic'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '난이도: ${'⭐' * (detail['difficulty'] as int? ?? 3)} | ${detail['estimatedDuration'] ?? 0}분',
                            style: const TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _parseScript(detail['script'] ?? '').map((section) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF595048),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getSectionColor(section['title']!).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getSectionIcon(section['title']!),
                                    color: _getSectionColor(section['title']!),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      section['title']!,
                                      style: TextStyle(
                                        color: _getSectionColor(section['title']!),
                                        fontFamily: 'JoseonGulim',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                section['content']!,
                                style: const TextStyle(
                                  color: Color(0xFFD9D4D2),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 16,
                                  height: 1.8,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteLecture(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text('삭제 확인', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
        content: Text(
          '$name 강의를 삭제하시겠습니까?',
          style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
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
      final success = await ApiService.deleteAILecture(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '강의가 삭제되었습니다' : '삭제 실패'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _loadLectures();
      }
    }
  }
}
