import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class BuildMakerScreen extends StatefulWidget {
  final Student student;
  const BuildMakerScreen({super.key, required this.student});

  @override
  State<BuildMakerScreen> createState() => _BuildMakerScreenState();
}

class _BuildMakerScreenState extends State<BuildMakerScreen> {
  List<Map<String, dynamic>> _lectures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  Future<void> _loadLectures() async {
    final lectures = await ApiService.getAILectures();
    setState(() {
      _lectures = lectures;
      _isLoading = false;
    });
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
        title: const Text('🤖 AI 강의', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _lectures.isEmpty
              ? const Center(child: Text('강의가 없습니다', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _lectures.length,
                  itemBuilder: (context, i) {
                    final lec = _lectures[i];
                    return Card(
                      color: const Color(0xFF595048),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.school, color: Color(0xFF4CAF50)),
                        title: Text(lec['lectureName'] ?? '', style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
                        subtitle: Text('난이도 ${lec['difficulty']} | ${lec['estimatedDuration']}분', style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF736A63)),
                        onTap: () => _openLecture(lec['id'], lec),
                      ),
                    );
                  },
                ),
    );
  }

  void _openLecture(int id, Map<String, dynamic> lectureInfo) async {
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
                  thumbVisibility: false,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._parseScript(detail['script'] ?? '').map((section) {
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
                        }),
                      ],
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
}
