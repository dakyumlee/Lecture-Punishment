import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/game_provider.dart';
import 'dungeon_screen.dart';

class DungeonEntranceScreen extends StatefulWidget {
  final Student student;
  const DungeonEntranceScreen({super.key, required this.student});
  @override
  State<DungeonEntranceScreen> createState() => _DungeonEntranceScreenState();
}

class _DungeonEntranceScreenState extends State<DungeonEntranceScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDungeon();
  }

  Future<void> _loadDungeon() async {
    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      await provider.loadCurrentBoss();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF00010D),
        appBar: AppBar(
          title: const Text('던전 입장', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
          backgroundColor: const Color(0xFF595048),
          iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF00010D),
        appBar: AppBar(
          title: const Text('던전 입장', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
          backgroundColor: const Color(0xFF595048),
          iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Color(0xFF595048)),
              const SizedBox(height: 24),
              Text(
                '던전을 불러올 수 없습니다',
                style: const TextStyle(
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
        ),
      );
    }

    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        if (provider.currentBoss == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF00010D),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '오늘의 보스가 없습니다',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 20,
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
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF00010D),
          appBar: AppBar(
            title: const Text('던전 입장', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
            backgroundColor: const Color(0xFF595048),
            iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    provider.currentBoss!.name,
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF595048),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber, size: 80, color: Color(0xFFD9D4D2)),
                        const SizedBox(height: 16),
                        const Text(
                          '안 외웠으면 뒤진다',
                          style: TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DungeonScreen(student: widget.student),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D0D0D),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          ),
                          child: const Text(
                            '입장',
                            style: TextStyle(
                              fontFamily: 'JoseonGulim',
                              fontSize: 20,
                              color: Color(0xFFD9D4D2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}