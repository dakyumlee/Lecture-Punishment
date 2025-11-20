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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('🤖 AI 강의', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        onTap: () => _openLecture(lec['id']),
                      ),
                    );
                  },
                ),
    );
  }

  void _openLecture(int id) async {
    final detail = await ApiService.getAILectureDetail(id);
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF00010D),
          appBar: AppBar(
            title: Text(detail['lectureName'] ?? '', style: const TextStyle(fontFamily: 'JoseonGulim')),
            backgroundColor: const Color(0xFF595048),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF595048),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                detail['script'] ?? '',
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim', fontSize: 16, height: 1.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
