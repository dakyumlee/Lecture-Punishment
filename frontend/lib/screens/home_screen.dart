import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'dungeon_screen.dart';
import 'worksheet_list_screen.dart';
import 'ranking_screen.dart';
import 'shop_screen.dart';
import 'my_page_screen.dart';
import 'instructor_stats_screen.dart';
import 'login_screen.dart';
import 'raid_screen.dart';
import 'mental_recovery_screen.dart';
import 'rage_memory_screen.dart';

class HomeScreen extends StatefulWidget {
  final Student initialStudent;
  const HomeScreen({super.key, required this.initialStudent});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Student student;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    student = widget.initialStudent;
    _refreshStudent();
  }

  Future<void> _refreshStudent() async {
    try {
      setState(() => _isLoading = true);
      final updated = await ApiService().getStudent(student.id);
      setState(() {
        student = updated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '허태훈의 분노 던전',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.school, color: Color(0xFFD9D4D2)),
            tooltip: '강사 정보',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InstructorStatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFFD9D4D2)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
              _refreshStudent();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD9D4D2)),
            onPressed: _refreshStudent,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD9D4D2)),
            tooltip: '로그아웃',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : RefreshIndicator(
              onRefresh: _refreshStudent,
              color: const Color(0xFFD9D4D2),
              backgroundColor: const Color(0xFF595048),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF595048),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0D0D),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                student.characterExpression ?? '😊',
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            student.displayName,
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '@${student.username}',
                            style: const TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('레벨', '${student.level}'),
                              _buildStatColumn('EXP', '${student.exp}'),
                              _buildStatColumn('포인트', '${student.points}'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: student.exp / (student.level * 100),
                            backgroundColor: const Color(0xFF736A63),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD9D4D2)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '다음 레벨까지 ${(student.level * 100) - student.exp} EXP',
                            style: const TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMenuButton(
                      context,
                      '🏰 던전 입장',
                      '오늘의 보스와 대결하기',
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DungeonScreen(student: student),
                          ),
                        );
                        _refreshStudent();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '🎮 레이드 참여',
                      '팀원들과 함께 거대 보스 토벌',
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RaidScreen(student: student),
                          ),
                        );
                        _refreshStudent();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '😤 강사 정보',
                      '허태훈 강사의 현재 상태',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InstructorStatsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '📝 문제지 풀기',
                      'PDF 문제지 도전하기',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorksheetListScreen(studentId: student.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '💪 멘탈 회복',
                      '힘들 땐 잠깐 쉬어가기',
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MentalRecoveryScreen(student: student),
                          ),
                        );
                        _refreshStudent();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '📖 분노 로그북',
                      '허태훈의 분노 기록 보기',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RageMemoryScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '🛒 상점',
                      '포인트로 아이템 구매',
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopScreen(student: student),
                          ),
                        );
                        _refreshStudent();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                      context,
                      '🏆 랭킹',
                      '다른 학생들과 경쟁하기',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RankingScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 20,
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
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFD9D4D2), size: 20),
          ],
        ),
      ),
    );
  }
}
