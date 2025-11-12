import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'worksheet_create_screen.dart';
import 'worksheet_manage_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/admin/stats'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '관리자 대시보드',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD9D4D2)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_stats != null) ...[
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('총 학생', '${_stats!['totalStudents']}명', Icons.people)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('총 수업', '${_stats!['totalLessons']}개', Icons.book)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('정답률', '${_stats!['successRate']}', Icons.check_circle)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('총 문제', '${_stats!['totalQuizzes']}개', Icons.quiz)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Text(
                    '수업 관리',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '📚 수업 생성',
                    '새로운 수업 만들기',
                    () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => _buildCreateLessonDialog(),
                      );
                      if (result == true) _loadStats();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '📋 수업 목록',
                    '등록된 수업 확인',
                    () async {
                      await _showLessons();
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '문제지 관리',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '📝 문제지 생성',
                    '새로운 문제지 만들기',
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorksheetCreateScreen(),
                        ),
                      );
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('문제지가 생성되었습니다!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '📑 문제지 관리',
                    '문제지 확인 및 문제 추가',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorksheetManageScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '학생 관리',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '👥 학생 목록',
                    '등록된 학생 확인',
                    () async {
                      await _showStudents();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD9D4D2), size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF595048),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF736A63), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFD9D4D2), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateLessonDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    return AlertDialog(
      backgroundColor: const Color(0xFF595048),
      title: const Text(
        '수업 생성',
        style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            style: const TextStyle(color: Color(0xFFD9D4D2)),
            decoration: const InputDecoration(
              labelText: '수업 제목',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
            ),
          ),
          TextField(
            controller: subjectController,
            style: const TextStyle(color: Color(0xFFD9D4D2)),
            decoration: const InputDecoration(
              labelText: '과목',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
        ),
        TextButton(
          onPressed: () async {
            try {
              await http.post(
                Uri.parse('http://localhost:8080/api/admin/lessons'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'title': titleController.text,
                  'subject': subjectController.text,
                }),
              );
              if (context.mounted) Navigator.pop(context, true);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('오류: $e')),
                );
              }
            }
          },
          child: const Text('생성', style: TextStyle(color: Color(0xFFD9D4D2))),
        ),
      ],
    );
  }

  Future<void> _showLessons() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/admin/lessons'));
      if (response.statusCode == 200) {
        final lessons = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF595048),
              title: const Text('수업 목록', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return ListTile(
                      title: Text(lesson['title'], style: const TextStyle(color: Color(0xFFD9D4D2))),
                      subtitle: Text(lesson['subject'], style: const TextStyle(color: Color(0xFF736A63))),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: Color(0xFFD9D4D2))),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  Future<void> _showStudents() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/admin/students'));
      if (response.statusCode == 200) {
        final students = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF595048),
              title: const Text('학생 목록', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student['displayName'], style: const TextStyle(color: Color(0xFFD9D4D2))),
                      subtitle: Text('Lv.${student['level']} | ${student['username']}', 
                        style: const TextStyle(color: Color(0xFF736A63))),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: Color(0xFFD9D4D2))),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }
}
