import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class DungeonEntranceScreen extends StatefulWidget {
  final Student student;
  final String lessonId;
  
  const DungeonEntranceScreen({
    super.key, 
    required this.student,
    required this.lessonId,
  });

  @override
  State<DungeonEntranceScreen> createState() => _DungeonEntranceScreenState();
}

class _DungeonEntranceScreenState extends State<DungeonEntranceScreen> {
  Map<String, dynamic>? _entrance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntrance();
  }

  Future<void> _loadEntrance() async {
    try {
      final entrance = await ApiService.getDungeonEntrance(widget.lessonId);
      setState(() {
        _entrance = entrance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('던전 정보를 불러올 수 없습니다: $e')),
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
          '던전 입장',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _entrance == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 80, color: Color(0xFF595048)),
                      const SizedBox(height: 24),
                      const Text(
                        '던전 정보를 불러올 수 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text(
                          '돌아가기',
                          style: TextStyle(
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                            color: Color(0xFFD9D4D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          '오늘의 보스',
                          style: TextStyle(
                            color: Color(0xFF736A63),
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _entrance!['bossName'] ?? '보스',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_entrance!['bossSubtitle'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _entrance!['bossSubtitle'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 16,
                            ),
                          ),
                        ],
                        const SizedBox(height: 48),
                        Row(
                          children: [
                            ...List.generate(
                              _entrance!['difficultyStars'] ?? 3,
                              (index) => const Icon(
                                Icons.star,
                                color: Color(0xFFD9D4D2),
                                size: 24,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF595048),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00010D),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.warning_amber,
                                  size: 60,
                                  color: Color(0xFFD9D4D2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _entrance!['instructorName'] ?? '허태훈',
                                style: const TextStyle(
                                  color: Color(0xFF736A63),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"${_entrance!['entranceDialogue'] ?? '안 외웠으면 뒤진다'}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFD9D4D2),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _enterDungeon(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D0D0D),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFD9D4D2), width: 2),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Color(0xFFD9D4D2)),
                                SizedBox(width: 12),
                                Text(
                                  '던전 입장',
                                  style: TextStyle(
                                    fontFamily: 'JoseonGulim',
                                    fontSize: 20,
                                    color: Color(0xFFD9D4D2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            '돌아가기',
                            style: TextStyle(
                              fontFamily: 'JoseonGulim',
                              fontSize: 16,
                              color: Color(0xFF736A63),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  void _enterDungeon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          bossId: _entrance?['bossId'],
          student: widget.student,
        ),
      ),
    );
  }
}
