import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'worksheet_create_screen.dart';
import 'worksheet_manage_screen.dart';
import 'group_manage_screen.dart';
import 'grading_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  void initState() {
    super.initState();
    _loadStats();
  }
  Future<void> _loadStats() async {
    try {
      final stats = await ApiService.getAdminStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
                        Expanded(child: _buildStatCard('정답률', '${_stats!['successRate']}', Icons.check_circle)),
                        Expanded(child: _buildStatCard('총 문제', '${_stats!['totalQuizzes']}개', Icons.quiz)),
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
                    '📋 수업 목록',
                    '등록된 수업 확인 및 삭제',
                      await _showLessons();
                    '문제지 관리',
                    '📝 문제지 생성',
                    '새로운 문제지 만들기',
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorksheetCreateScreen(),
                        ),
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('문제지가 생성되었습니다!')),
                        );
                      }
                    '📑 문제지 관리',
                    '문제지 확인, 문제 추가 및 삭제',
                    () {
                      Navigator.push(
                          builder: (context) => const WorksheetManageScreen(),
                    '그룹 관리',
                    '👥 그룹 관리',
                    '년도/과정/기간별 그룹 생성 및 관리',
                          builder: (context) => const GroupManageScreen(),
                    '채점 관리',
                    '✏️ 제출 답안 채점',
                    '학생들이 제출한 답안 확인 및 채점',
                          builder: (context) => const GradingScreen(),
                    '학생 관리',
                    '👥 학생 목록',
                    '등록된 학생 확인 및 삭제',
                      await _showStudents();
                ],
              ),
            ),
    );
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
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
            label,
              color: Color(0xFF736A63),
              fontSize: 12,
  Widget _buildActionButton(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF595048),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF736A63), width: 1),
        child: Row(
          children: [
            Expanded(
                crossAxisAlignment: CrossAxisAlignment.start,
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                  const SizedBox(height: 4),
                    subtitle,
                      color: Color(0xFF736A63),
                      fontSize: 12,
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFD9D4D2), size: 16),
          ],
  Widget _buildCreateLessonDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    return AlertDialog(
      backgroundColor: const Color(0xFF595048),
      title: const Text(
        '수업 생성',
        style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
          TextField(
            controller: titleController,
            style: const TextStyle(color: Color(0xFFD9D4D2)),
            decoration: const InputDecoration(
              labelText: '수업 제목',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
            controller: subjectController,
              labelText: '과목',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
          onPressed: () async {
            try {
              await ApiService.createLesson(
                title: titleController.text,
                description: subjectController.text,
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
      ],
  Future<void> _showLessons() async {
      final lessons = await ApiService.getAdminLessons();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: const Text('수업 목록', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
            content: SizedBox(
              width: double.maxFinite,
              child: lessons.isEmpty
                  ? const Text('등록된 수업이 없습니다', style: TextStyle(color: Color(0xFF736A63)))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        return ListTile(
                          title: Text(lesson['title'], style: const TextStyle(color: Color(0xFFD9D4D2))),
                          subtitle: Text(lesson['subject'], style: const TextStyle(color: Color(0xFF736A63))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF595048),
                                  title: const Text('삭제 확인', style: TextStyle(color: Color(0xFFD9D4D2))),
                                  content: Text('${lesson['title']} 수업을 삭제하시겠습니까?',
                                      style: const TextStyle(color: Color(0xFFD9D4D2))),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
                                    ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              );
                              
                              if (confirm == true) {
                                final success = await ApiService.deleteLesson(lesson['id']);
                                if (success) {
                                  Navigator.pop(context);
                                  _showLessons();
                                  _loadStats();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('수업이 삭제되었습니다')),
                                  );
                                }
                              }
                            },
                          ),
                      },
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기', style: TextStyle(color: Color(0xFFD9D4D2))),
            ],
        );
      }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
  Future<void> _showStudents() async {
      final students = await ApiService.getAdminStudents();
            title: const Text('학생 목록', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
              child: students.isEmpty
                  ? const Text('등록된 학생이 없습니다', style: TextStyle(color: Color(0xFF736A63)))
                      itemCount: students.length,
                        final student = students[index];
                          title: Text(student['displayName'], style: const TextStyle(color: Color(0xFFD9D4D2))),
                          subtitle: Text('Lv.${student['level']} | ${student['username']}', 
                            style: const TextStyle(color: Color(0xFF736A63))),
                                  content: Text('${student['displayName']} 학생을 삭제하시겠습니까?',
                                final success = await ApiService.deleteStudent(student['id']);
                                  _showStudents();
                                    const SnackBar(content: Text('학생이 삭제되었습니다')),
