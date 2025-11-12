import 'package:flutter/material.dart';
import '../models/student.dart';
import 'dungeon_entrance_screen.dart';
import 'worksheet_list_screen.dart';
import 'ranking_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  final Student student;

  const HomeScreen({super.key, required this.student});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD9D4D2)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF00010D),
                    child: Icon(Icons.person, size: 60, color: Color(0xFFD9D4D2)),
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
                  const SizedBox(height: 16),
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
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DungeonEntranceScreen(student: student),
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
              '🛒 상점',
              '포인트로 아이템 구매',
              () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopScreen(student: student),
                  ),
                );
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('구매 완료! 새로고침 해주세요.')),
                  );
                }
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
