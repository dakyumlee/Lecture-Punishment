import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminStudentScreen extends StatefulWidget {
  const AdminStudentScreen({super.key});
  @override
  State<AdminStudentScreen> createState() => _AdminStudentScreenState();
}
class _AdminStudentScreenState extends State<AdminStudentScreen> {
  List<dynamic> _students = [];
  List<dynamic> _groups = [];
  bool _isLoading = true;
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final students = await ApiService.getAllStudents();
      final groups = await ApiService.getAllGroups();
      setState(() {
        _students = students;
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로드 실패: $e')),
        );
      }
    }
  Future<void> _showAddStudentDialog() async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final displayNameController = TextEditingController();
    String? selectedGroupId;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF595048),
          title: const Text(
            '학생 추가',
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '아이디를 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                  controller: displayNameController,
                    labelText: '이름',
                  validator: (v) => v?.isEmpty ?? true ? '이름을 입력하세요' : null,
                DropdownButtonFormField<String>(
                  value: selectedGroupId,
                  dropdownColor: const Color(0xFF595048),
                    labelText: '그룹 (선택)',
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('그룹 없음', style: TextStyle(color: Color(0xFF736A63))),
                    ),
                    ..._groups.map((group) => DropdownMenuItem(
                      value: group['id'],
                      child: Text(group['groupName'], style: TextStyle(color: Color(0xFFD9D4D2))),
                    )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGroupId = value;
                    });
                  },
              ],
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await ApiService.createStudent(
                      username: usernameController.text,
                      displayName: displayNameController.text,
                      groupId: selectedGroupId,
                    );
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('학생이 추가되었습니다')),
                  } catch (e) {
                      SnackBar(content: Text('추가 실패: $e')),
                  }
                }
              },
              child: const Text('추가', style: TextStyle(color: Color(0xFFD9D4D2))),
          ],
        ),
      ),
    );
  Future<void> _deleteStudent(String studentId, String studentName) async {
    final confirm = await showDialog<bool>(
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '학생 삭제',
          style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        content: Text(
          '$studentName 학생을 삭제하시겠습니까?',
          style: const TextStyle(color: Color(0xFFD9D4D2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
        ],
    if (confirm == true) {
      try {
        await ApiService.deleteStudent(studentId);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('학생이 삭제되었습니다')),
          );
        }
      } catch (e) {
            SnackBar(content: Text('삭제 실패: $e')),
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
          '학생 관리',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddStudentDialog,
            tooltip: '학생 추가',
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
            )
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off,
                        size: 80,
                        color: Color(0xFF595048),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '등록된 학생이 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddStudentDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('학생 추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          foregroundColor: const Color(0xFFD9D4D2),
                    ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      color: const Color(0xFF595048),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00010D),
                          child: Text(
                            student['displayName'][0],
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                            ),
                          ),
                        title: Text(
                          student['displayName'],
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontWeight: FontWeight.bold,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${student['username']}',
                              style: const TextStyle(color: Color(0xFF736A63)),
                            if (student['group'] != null)
                              Text(
                                '그룹: ${student['group']['groupName']}',
                                style: const TextStyle(color: Color(0xFF736A63)),
                              ),
                          ],
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00010D),
                                borderRadius: BorderRadius.circular(4),
                              child: Text(
                                'Lv.${student['level']}',
                                style: const TextStyle(
                                  color: Color(0xFFD9D4D2),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 12,
                                ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _deleteStudent(student['id'], student['displayName']),
