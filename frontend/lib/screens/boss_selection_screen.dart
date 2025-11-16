import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/boss.dart';
import 'quiz_screen.dart';

class BossSelectionScreen extends StatefulWidget {
  @override
  _BossSelectionScreenState createState() => _BossSelectionScreenState();
}

class _BossSelectionScreenState extends State<BossSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadCurrentBoss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00010D),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)));
          }

          Boss? boss = gameProvider.currentBoss;
          if (boss == null) {
            return Center(
              child: Text(
                '오늘의 보스가 없습니다',
                style: TextStyle(color: Color(0xFFD9D4D2), fontSize: 24),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '오늘의 보스',
                  style: TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontSize: 32,
                    fontFamily: 'JoseonGulim',
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xFF595048),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        boss.name,
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JoseonGulim',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        boss.description,
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontSize: 20,
                          fontFamily: 'JoseonGulim',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'HP: ${boss.maxHp}',
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontSize: 24,
                          fontFamily: 'JoseonGulim',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xFF595048), width: 2),
                  ),
                  child: Text(
                    '"안 외웠으면 뒤진다"',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'JoseonGulim',
                    ),
                  ),
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () async {
                    await gameProvider.loadTodayDungeon();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF595048),
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    '던전 입장',
                    style: TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JoseonGulim',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
