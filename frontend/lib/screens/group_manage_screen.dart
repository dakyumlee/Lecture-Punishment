import '../services/api_service.dart';
import 'package:flutter/material.dart';

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

  String _formatStudentInfo(dynamic student) {
    final birthDate = student['birthDate'];
    if (birthDate != null && birthDate.toString().isNotEmpty) {
      return '${student['displayName']} ($birthDate)';
    }
    return '${student['displayName']} (${student['username']})';
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final yearController = TextEditingController();
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
                    labelText: '기간',
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
                    labelText: '설명 (선택)',
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
                    name: nameController.text,
                    year: int.tryParse(yearController.text),
                    course: courseController.text,
                    period: periodController.text,
                    description: descController.text.isEmpty ? null : descController.text,
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
        await ApiService.deleteGroup(groupId);
        _loadGroups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('그룹이 삭제되었습니다')),
          );
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

  Future<void> _showAddStudentDialog(String groupId, String groupName) async {
    try {
      final allStudents = await ApiService.getAllStudents();
      final groupStudents = await ApiService.getGroupStudents(groupId);
      final groupStudentIds = groupStudents.map((s) => s['id']).toSet();
      final availableStudents = allStudents.where((s) => !groupStudentIds.contains(s['id'])).toList();

      if (!mounted) return;

      if (availableStudents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('추가할 수 있는 학생이 없습니다')),
        );
        return;
      }

      String? selectedStudentId;

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: Text(
              '$groupName에 학생 추가',
              style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStudentId,
                    dropdownColor: const Color(0xFF595048),
                    decoration: const InputDecoration(
                      labelText: '학생 선택',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                    ),
                    items: availableStudents.map<DropdownMenuItem<String>>((student) {
                      return DropdownMenuItem<String>(
                        value: student['id'],
                        child: Text(
                          _formatStudentInfo(student),
                          style: const TextStyle(color: Color(0xFFD9D4D2)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStudentId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
              ),
              TextButton(
                onPressed: selectedStudentId == null
                  ? null
                  : () async {
                      try {
                        await ApiService.assignStudentToGroup(
                          groupId: groupId,
                          studentId: selectedStudentId!,
                        );
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('학생을 추가했습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('추가 실패: $e')),
                        );
                      }
                    },
                child: const Text('추가', style: TextStyle(color: Color(0xFFD9D4D2))),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학생 목록 로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _showGroupDetail(dynamic group) async {
    try {
      final students = await ApiService.getGroupStudents(group['id']);
      
      if (!mounted) return;
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF595048),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  group['groupName'],
                  style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Color(0xFFD9D4D2)),
                onPressed: () async {
                  try {
                    await ApiService.downloadGroupExcel(group['id'], group['groupName']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Excel 다운로드 시작')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('다운로드 실패: $e')),
                    );
                  }
                },
                tooltip: 'Excel 다운로드',
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group['year'] != null)
                  Text(
                    '년도: ${group['year']}',
                    style: const TextStyle(color: Color(0xFF736A63)),
                  ),
                if (group['course'] != null)
                  Text(
                    '과정: ${group['course']}',
                    style: const TextStyle(color: Color(0xFF736A63)),
                  ),
                if (group['period'] != null)
                  Text(
                    '기간: ${group['period']}',
                    style: const TextStyle(color: Color(0xFF736A63)),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '학생 목록',
                      style: TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _showAddStudentDialog(group['id'], group['groupName']);
                        _showGroupDetail(group);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('학생 추가', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D0D0D),
                        foregroundColor: const Color(0xFFD9D4D2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF736A63)),
                Flexible(
                  child: students.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              '학생이 없습니다',
                              style: TextStyle(color: Color(0xFF736A63)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                _formatStudentInfo(student),
                                style: const TextStyle(color: Color(0xFFD9D4D2)),
                              ),
                              subtitle: Text(
                                '학생ID: ${student['username']}',
                                style: const TextStyle(color: Color(0xFF736A63), fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                onPressed: () async {
                                  try {
                                    await ApiService.removeStudentFromGroup(
                                      groupId: group['id'],
                                      studentId: student['id'],
                                    );
                                    Navigator.pop(context);
                                    _showGroupDetail(group);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('학생 제거 완료')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('제거 실패: $e')),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로드 실패: $e')),
        );
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
            icon: const Icon(Icons.add_circle),
            onPressed: _showCreateDialog,
            tooltip: '그룹 생성',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () async {
              try {
                await ApiService.downloadAllStudentsExcel();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('전체 학생 Excel 다운로드 시작')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('다운로드 실패: $e')),
                );
              }
            },
            tooltip: '전체 학생 Excel',
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
                        Icons.group_off,
                        size: 80,
                        color: Color(0xFF595048),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '생성된 그룹이 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('그룹 생성'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          foregroundColor: const Color(0xFFD9D4D2),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return Card(
                      color: const Color(0xFF595048),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          group['groupName'],
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (group['year'] != null && group['course'] != null)
                              Text(
                                '${group['year']} - ${group['course']}',
                                style: const TextStyle(color: Color(0xFF736A63)),
                              ),
                            if (group['period'] != null)
                              Text(
                                group['period'],
                                style: const TextStyle(color: Color(0xFF736A63)),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.auto_awesome, color: Color(0xFF4CAF50)),
                              onPressed: () => _showEvolutionDialog(group),
                              tooltip: '아빠 모드',
                            ),
                            IconButton(
                              icon: const Icon(Icons.info, color: Color(0xFFD9D4D2)),
                              onPressed: () => _showGroupDetail(group),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGroup(group['id'], group['groupName']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showEvolutionDialog(Map<String, dynamic> group) async {
    final status = await ApiService.getGroupEvolutionStatus(group['id']);
    final isEvolved = status['isEvolved'] ?? false;
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: Text(
          isEvolved ? '🎯 진화 초기화' : '👨 아빠 모드로 진화',
          style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        ),
        content: Text(
          isEvolved
              ? '${group['groupName']} 그룹을 분노 모드로 되돌리시겠습니까?'
              : '${group['groupName']} 그룹을 아빠 허태훈 모드로 진화시키시겠습니까?\n\n이 그룹의 학생들은 따뜻한 아빠 허태훈을 만나게 됩니다.',
          style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = isEvolved
                  ? await ApiService.resetGroupEvolution(group['id'])
                  : await ApiService.evolveGroup(group['id']);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isEvolved ? '분노 모드로 되돌렸습니다' : '아빠 모드로 진화했습니다! 🎉')
                          : '진화 실패',
                      style: const TextStyle(fontFamily: 'JoseonGulim'),
                    ),
                    backgroundColor: success ? const Color(0xFF4CAF50) : Colors.red,
                  ),
                );
                _loadGroups();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isEvolved ? Colors.orange : const Color(0xFF4CAF50),
            ),
            child: Text(
              isEvolved ? '초기화' : '진화',
              style: const TextStyle(color: Colors.white, fontFamily: 'JoseonGulim'),
            ),
          ),
        ],
      ),
    );
  }
}
