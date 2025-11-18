import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'dungeon_entrance_screen.dart';

class DungeonScreen extends StatefulWidget {
  final Student student;
  const DungeonScreen({super.key, required this.student});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  List<dynamic> _dungeons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDungeons();
  }

  Future<void> _loadDungeons() async {
    try {
      print('Loading dungeons for student: ${widget.student.id}');
      final dungeons = await ApiService.getAvailableDungeons(widget.student.id);
      print('Loaded dungeons: ${dungeons.length} items');
      print('Dungeons data: $dungeons');
      
      setState(() {
        _dungeons = dungeons;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading dungeons: $e');
      print('Stack trace: $stackTrace');
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('던전 목록을 불러올 수 없습니다: $e')),
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
          '허태훈의 분노 던전',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _dungeons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.castle, size: 80, color: Color(0xFF736A63)),
                      const SizedBox(height: 16),
                      const Text(
                        '아직 입장 가능한 던전이 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Color(0xFFD9D4D2),
                  backgroundColor: Color(0xFF595048),
                  onRefresh: _loadDungeons,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dungeons.length,
                    itemBuilder: (context, index) {
                      final dungeon = _dungeons[index];
                      return _buildDungeonCard(dungeon);
                    },
                  ),
                ),
    );
  }

  Widget _buildDungeonCard(Map<String, dynamic> dungeon) {
    final isDefeated = dungeon['isDefeated'] ?? false;
    final currentHp = dungeon['currentHp'] ?? 1000;
    final totalHp = dungeon['totalHp'] ?? 1000;
    final hpPercentage = totalHp > 0 ? (currentHp / totalHp) : 1.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefeated ? Color(0xFF736A63) : Color(0xFFD9D4D2),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDefeated ? null : () => _enterDungeon(dungeon),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDefeated ? Icons.check_circle : Icons.dangerous,
                      color: isDefeated ? Color(0xFF736A63) : Color(0xFFD9D4D2),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dungeon['title'] ?? '수업',
                            style: TextStyle(
                              color: isDefeated ? Color(0xFF736A63) : Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dungeon['bossName'] ?? '보스',
                            style: TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDefeated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF736A63),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '클리어',
                          style: TextStyle(
                            color: Color(0xFF00010D),
                            fontFamily: 'JoseonGulim',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ...List.generate(
                      dungeon['difficulty'] ?? 3,
                      (index) => Icon(
                        Icons.star,
                        color: Color(0xFFD9D4D2),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.${dungeon['difficulty'] ?? 3}',
                      style: const TextStyle(
                        color: Color(0xFF736A63),
                        fontFamily: 'JoseonGulim',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '보스 체력',
                          style: TextStyle(
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$currentHp / $totalHp',
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: hpPercentage,
                        backgroundColor: Color(0xFF0D0D0D),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDefeated ? Color(0xFF736A63) : Color(0xFFD9D4D2),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                if (!isDefeated) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_forward, color: Color(0xFFD9D4D2), size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '던전 입장',
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enterDungeon(Map<String, dynamic> dungeon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DungeonEntranceScreen(
          student: widget.student,
          lessonId: dungeon['lessonId'],
        ),
      ),
    ).then((_) => _loadDungeons());
  }
}
