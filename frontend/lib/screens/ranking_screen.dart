import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<dynamic> _rankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final data = await ApiService.getRanking();
      setState(() {
        _rankings = data;
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
        title: const Text('랭킹', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _rankings.isEmpty
              ? const Center(
                  child: Text(
                    '랭킹 데이터가 없습니다',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rankings.length,
                  itemBuilder: (context, index) {
                    final student = _rankings[index];
                    final rank = index + 1;
                    final hasRageResistance = rank <= 10;
                    return Card(
                      color: const Color(0xFF595048),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: rank <= 3 ? const Color(0xFFD9D4D2) : const Color(0xFF0D0D0D),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    color: rank <= 3 ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
                                    fontFamily: 'JoseonGulim',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        student['displayName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Color(0xFFD9D4D2),
                                          fontFamily: 'JoseonGulim',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (hasRageResistance) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D0D0D),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '분노 내성 +10%',
                                            style: TextStyle(
                                              color: Color(0xFFD9D4D2),
                                              fontFamily: 'JoseonGulim',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lv.${student['level']} • ${student['exp']} EXP',
                                    style: const TextStyle(
                                      color: Color(0xFF736A63),
                                      fontFamily: 'JoseonGulim',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}