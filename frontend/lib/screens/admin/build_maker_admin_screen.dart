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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('🤖 AI 강의 생성', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    onTap: () => _showDetail(lec['id']),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(onPressed: _generate, child: const Text('생성')),
        ],
      ),
    );
  }

  void _showDetail(int id) async {
    final detail = await ApiService.getAILectureDetail(id);
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: Text(detail['lectureName'] ?? '', style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
        content: SingleChildScrollView(
          child: Text(detail['script'] ?? '', style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ],
      ),
    );
  }
}
