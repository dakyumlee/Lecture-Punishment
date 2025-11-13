import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GroupManageScreen extends StatefulWidget {
  const GroupManageScreen({super.key});

  @override
  State<GroupManageScreen> createState() => _GroupManageScreenState();
}

class _GroupManageScreenState extends State<GroupManageScreen> {
  List<dynamic> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    try {
      final groups = await ApiService.getAllGroups();
      setState(() {
        _groups = groups;
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

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final yearController = TextEditingController(text: DateTime.now().year.toString());
    final courseController = TextEditingController();
    final periodController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '그룹 생성',
          style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '그룹명',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '그룹명을 입력하세요' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: yearController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '년도',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '년도를 입력하세요' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: courseController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '과정',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '과정을 입력하세요' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: periodController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '기간 (예: 2025.01-2025.06)',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '기간을 입력하세요' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '설명',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ApiService.createGroup(
                    groupName: nameController.text,
                    year: int.parse(yearController.text),
                    course: courseController.text,
                    period: periodController.text,
                    description: descController.text,
                  );
                  Navigator.pop(context);
                  _loadGroups();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('그룹이 생성되었습니다')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('생성 실패: $e')),
                  );
                }
              }
            },
            child: const Text('생성', style: TextStyle(color: Color(0xFFD9D4D2))),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroup(String groupId, String groupName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '그룹 삭제',
          style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        ),
        content: Text(
          '$groupName 그룹을 삭제하시겠습니까?',
          style: const TextStyle(color: Color(0xFFD9D4D2)),
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
      try {
        final success = await ApiService.deleteGroup(groupId);
        if (success) {
          _loadGroups();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('그룹이 삭제되었습니다')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '그룹 관리',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                await ApiService.downloadAllStudentsExcel();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('전체 학생 Excel 다운로드 완료!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('다운로드 실패: $e')),
                  );
                }
              }
            },
            tooltip: '전체 학생 Excel 다운로드',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
            )
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 64,
                        color: Color(0xFF595048),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '그룹이 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '새로운 그룹을 생성하세요',
                        style: TextStyle(
                          color: Color(0xFF595048),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGroups,
                  color: const Color(0xFFD9D4D2),
                  backgroundColor: const Color(0xFF595048),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _groups.length,
                    itemBuilder: (context, index) {
                      final group = _groups[index];
                      return _buildGroupCard(group);
                    },
                  ),
                ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    final groupName = group['groupName'] ?? '이름 없음';
    final year = group['year'] ?? 0;
    final course = group['course'] ?? '';
    final period = group['period'] ?? '';
    final description = group['description'] ?? '';
    final groupId = group['id'] ?? '';

    return Card(
      color: const Color(0xFF0D0D0D),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF595048)),
      ),
      child: ExpansionTile(
        title: Text(
          groupName,
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF595048),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$year년',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                course,
                style: const TextStyle(
                  color: Color(0xFF736A63),
                  fontFamily: 'JoseonGulim',
                ),
              ),
            ],
          ),
        ),
        iconColor: const Color(0xFFD9D4D2),
        collapsedIconColor: const Color(0xFF736A63),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (period.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF736A63), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        period,
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (description.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00010D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF736A63),
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showGroupStudents(groupId);
                        },
                        icon: const Icon(Icons.people, size: 18),
                        label: const Text('학생', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ApiService.downloadGroupExcel(groupId, groupName);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Excel 다운로드 완료!')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('다운로드 실패: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Excel', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF736A63),
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteGroup(groupId, groupName),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('삭제', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: const Color(0xFFD9D4D2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGroupStudents(String groupId) async {
    try {
      final students = await ApiService.getGroupStudents(groupId);
      final allStudents = await ApiService.getAdminStudents();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '그룹 학생 관리',
                  style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFFD9D4D2)),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddStudentDialog(groupId, students, allStudents);
                  },
                  tooltip: '학생 추가',
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: students.isEmpty
                  ? const Text(
                      '이 그룹에 학생이 없습니다',
                      style: TextStyle(color: Color(0xFF736A63)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          title: Text(
                            student['displayName'],
                            style: const TextStyle(color: Color(0xFFD9D4D2)),
                          ),
                          subtitle: Text(
                            'Lv.${student['level']} | ${student['username']}',
                            style: const TextStyle(color: Color(0xFF736A63)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF595048),
                                  title: const Text(
                                    '학생 제거',
                                    style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                                  ),
                                  content: Text(
                                    '${student['displayName']} 학생을 그룹에서 제거하시겠습니까?',
                                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('제거', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  final success = await ApiService.removeStudentFromGroup(
                                    studentId: student['id'],
                                    groupId: groupId,
                                  );
                                  
                                  if (success) {
                                    Navigator.pop(context);
                                    _showGroupStudents(groupId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${student['displayName']} 학생을 제거했습니다'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('제거 실패: $e')),
                                  );
                                }
                              }
                          ),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _showAddStudentDialog(
    String groupId,
    List<dynamic> groupStudents,
    List<dynamic> allStudents,
  ) async {
    final groupStudentIds = groupStudents.map((s) => s['id']).toSet();
    final availableStudents = allStudents
        .where((s) => !groupStudentIds.contains(s['id']))
        .toList();

    if (availableStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추가할 수 있는 학생이 없습니다')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: const Text(
          '학생 추가',
          style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableStudents.length,
            itemBuilder: (context, index) {
              final student = availableStudents[index];
              return ListTile(
                title: Text(
                  student['displayName'],
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                ),
                subtitle: Text(
                  'Lv.${student['level']} | ${student['username']}',
                  style: const TextStyle(color: Color(0xFF736A63)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () async {
                    try {
                      final success = await ApiService.assignStudentToGroup(
                        studentId: student['id'],
                        groupId: groupId,
                      );
                      
                      if (success) {
                        Navigator.pop(context);
                        _showGroupStudents(groupId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${student['displayName']} 학생을 추가했습니다'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('추가 실패: $e')),
                      );
                    }
                  },
                ),
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
