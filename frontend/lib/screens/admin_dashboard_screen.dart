import '../services/api_service.dart';
import '../widgets/instructor_status_widget.dart';
import 'package:flutter/material.dart';
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

  @override
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
                  const InstructorStatusWidget(),
                  const SizedBox(height: 24),
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
                        builder: (context) => const _CreateLessonDialog(),
                      );
                      if (result == true) {
                        _loadStats();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ 수업과 보스가 생성되었습니다!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '📋 수업 목록',
                    '등록된 수업 확인 및 삭제',
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
                    '📝 문제지 생성 및 관리',
                    'PDF OCR, 직접 작성, 문제 추가 및 삭제',
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
                    '그룹 관리',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '👥 그룹 관리',
                    '년도/과정/기간별 그룹 생성 및 관리',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroupManageScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '채점 관리',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    '✏️ 제출 답안 채점',
                    '학생들이 제출한 답안 확인 및 채점',
                    () async {
                      await _showSubmissions();
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
                    '등록된 학생 확인 및 삭제',
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
          const SizedBox(height: 4),
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

  Future<void> _showSubmissions() async {
    try {
      final submissions = await ApiService.getAllSubmissions();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: const Text(
              '제출 답안 목록',
              style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: submissions.isEmpty
                  ? const Text('제출된 답안이 없습니다', style: TextStyle(color: Color(0xFF736A63)))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final submission = submissions[index];
                        return ListTile(
                          title: Text(
                            submission['worksheetTitle'] ?? '문제지',
                            style: const TextStyle(color: Color(0xFFD9D4D2)),
                          ),
                          subtitle: Text(
                            '학생: ${submission['studentName'] ?? ''} | 점수: ${submission['score'] ?? 0}점',
                            style: const TextStyle(color: Color(0xFF736A63)),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD9D4D2)),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GradingScreen(submission: submission),
                              ),
                            );
                          },
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  Future<void> _showLessons() async {
    try {
      final lessons = await ApiService.getAdminLessons();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: const Text(
              '수업 목록',
              style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            ),
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
                          title: Text(
                            lesson['title'],
                            style: const TextStyle(color: Color(0xFFD9D4D2)),
                          ),
                          subtitle: Text(
                            lesson['subject'],
                            style: const TextStyle(color: Color(0xFF736A63)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF595048),
                                  title: const Text(
                                    '삭제 확인',
                                    style: TextStyle(color: Color(0xFFD9D4D2)),
                                  ),
                                  content: Text(
                                    '${lesson['title']} 수업을 삭제하시겠습니까?',
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
                                final success = await ApiService.deleteLesson(lesson['id']);
                                if (success && mounted) {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  Future<void> _showStudents() async {
    try {
      final students = await ApiService.getAdminStudents();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF595048),
            title: const Text(
              '학생 목록',
              style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: students.isEmpty
                  ? const Text('등록된 학생이 없습니다', style: TextStyle(color: Color(0xFF736A63)))
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF595048),
                                  title: const Text(
                                    '삭제 확인',
                                    style: TextStyle(color: Color(0xFFD9D4D2)),
                                  ),
                                  content: Text(
                                    '${student['displayName']} 학생을 삭제하시겠습니까?',
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
                                final success = await ApiService.deleteStudent(student['id']);
                                if (success && mounted) {
                                  Navigator.pop(context);
                                  _showStudents();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('학생이 삭제되었습니다')),
                                  );
                                }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }
}

class _CreateLessonDialog extends StatefulWidget {
  const _CreateLessonDialog();

  @override
  State<_CreateLessonDialog> createState() => _CreateLessonDialogState();
}

class _CreateLessonDialogState extends State<_CreateLessonDialog> {
  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  
  List<dynamic> _groups = [];
  String? _selectedGroupId;
  int _difficulty = 3;
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await ApiService.getActiveGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createLesson() async {
    if (titleController.text.isEmpty || subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('수업 제목과 과목을 입력해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      await ApiService.createLesson(
        title: titleController.text,
        description: subjectController.text,
        groupId: _selectedGroupId,
        difficulty: _difficulty,
      );
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isCreating = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDifficultyLabel(int diff) {
    switch (diff) {
      case 1: return '⭐ 입문 (HP 500, 문제 10개)';
      case 2: return '⭐⭐ 초급 (HP 1000, 문제 15개)';
      case 3: return '⭐⭐⭐ 중급 (HP 1500, 문제 20개)';
      case 4: return '⭐⭐⭐⭐ 상급 (HP 2500, 문제 25개)';
      case 5: return '⭐⭐⭐⭐⭐ 허태훈의 진노 (HP 5000, 문제 30개)';
      default: return '중급';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF595048),
      title: const Text(
        '수업 생성',
        style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
      ),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _isCreating
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Color(0xFFD9D4D2)),
                    SizedBox(height: 16),
                    Text(
                      '보스와 퀴즈를 생성 중...',
                      style: TextStyle(color: Color(0xFFD9D4D2)),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Color(0xFFD9D4D2)),
                        decoration: const InputDecoration(
                          labelText: '수업 제목',
                          labelStyle: TextStyle(color: Color(0xFF736A63)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF736A63)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: subjectController,
                        style: const TextStyle(color: Color(0xFFD9D4D2)),
                        decoration: const InputDecoration(
                          labelText: '과목',
                          labelStyle: TextStyle(color: Color(0xFF736A63)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF736A63)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '난이도 선택',
                            style: TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...[1, 2, 3, 4, 5].map((diff) {
                            bool isSelected = _difficulty == diff;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => setState(() => _difficulty = diff),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFF736A63) 
                                        : const Color(0xFF0D0D0D),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFFD9D4D2) 
                                          : const Color(0xFF736A63),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected 
                                            ? Icons.radio_button_checked 
                                            : Icons.radio_button_unchecked,
                                        color: const Color(0xFFD9D4D2),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _getDifficultyLabel(diff),
                                          style: TextStyle(
                                            color: const Color(0xFFD9D4D2),
                                            fontFamily: 'JoseonGulim',
                                            fontSize: 13,
                                            fontWeight: isSelected 
                                                ? FontWeight.bold 
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGroupId,
                        dropdownColor: const Color(0xFF595048),
                        style: const TextStyle(color: Color(0xFFD9D4D2)),
                        decoration: const InputDecoration(
                          labelText: '그룹 (선택사항)',
                          labelStyle: TextStyle(color: Color(0xFF736A63)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF736A63)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('전체 (그룹 없음)', style: TextStyle(color: Color(0xFF736A63))),
                          ),
                          ..._groups.map((group) {
                            return DropdownMenuItem<String>(
                              value: group['id'],
                              child: Text(
                                group['groupName'],
                                style: const TextStyle(color: Color(0xFFD9D4D2)),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedGroupId = value);
                        },
                      ),
                    ],
                  ),
                ),
      actions: _isCreating
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
              ),
              TextButton(
                onPressed: _createLesson,
                child: const Text('생성', style: TextStyle(color: Color(0xFFD9D4D2))),
              ),
            ],
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    super.dispose();
  }
}