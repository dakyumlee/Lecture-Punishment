import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _rankings = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadRankings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getRanking();
      setState(() {
        _rankings = data;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('랭킹을 불러올 수 없습니다: $e')),
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
          '🏆 클래스 랭킹',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD9D4D2)),
            onPressed: _loadRankings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _rankings.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildTopThree(),
                    Expanded(child: _buildRankingList()),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard, size: 80, color: Color(0xFF595048)),
          const SizedBox(height: 24),
          const Text(
            '아직 랭킹 데이터가 없습니다',
            style: TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadRankings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF595048),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              '새로고침',
              style: TextStyle(
                fontFamily: 'JoseonGulim',
                fontSize: 16,
                color: Color(0xFFD9D4D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    if (_rankings.length < 3) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF595048),
            const Color(0xFF00010D),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_rankings.length >= 2) _buildPodium(_rankings[1], 2, 120),
          if (_rankings.isNotEmpty) _buildPodium(_rankings[0], 1, 150),
          if (_rankings.length >= 3) _buildPodium(_rankings[2], 3, 100),
        ],
      ),
    );
  }

  Widget _buildPodium(dynamic student, int rank, double height) {
    String trophy = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
    Color podiumColor = rank == 1 
        ? const Color(0xFFD9D4D2)
        : rank == 2 
            ? const Color(0xFF736A63)
            : const Color(0xFF595048);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_animationController.value * 0.5),
          child: Opacity(
            opacity: _animationController.value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trophy,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: podiumColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Color(0xFF00010D),
                  fontFamily: 'JoseonGulim',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              student['displayName'] ?? 'Unknown',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lv.${student['level']}',
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: height,
            decoration: BoxDecoration(
              color: podiumColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: const Color(0xFFD9D4D2), width: 1),
            ),
            child: Center(
              child: Text(
                '${student['exp']}',
                style: const TextStyle(
                  color: Color(0xFF00010D),
                  fontFamily: 'JoseonGulim',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    List<dynamic> remainingRankings = _rankings.length > 3 
        ? _rankings.sublist(3) 
        : [];

    if (remainingRankings.isEmpty && _rankings.length <= 3) {
      return const SizedBox();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: remainingRankings.length,
      itemBuilder: (context, index) {
        final student = remainingRankings[index];
        final rank = index + 4;
        final hasRageResistance = rank <= 10;
        
        int totalQuestions = (student['totalCorrect'] ?? 0) + (student['totalWrong'] ?? 0);
        double accuracy = totalQuestions > 0 
            ? (student['totalCorrect'] ?? 0) * 100.0 / totalQuestions 
            : 0.0;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double delay = (index * 0.1).clamp(0.0, 1.0);
            double animValue = (_animationController.value - delay).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(0, 20 * (1 - animValue)),
              child: Opacity(
                opacity: animValue,
                child: child,
              ),
            );
          },
          child: Card(
            color: const Color(0xFF595048),
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: hasRageResistance ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
                width: hasRageResistance ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasRageResistance ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
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
                            Flexible(
                              child: Text(
                                student['displayName'] ?? 'Unknown',
                                style: const TextStyle(
                                  color: Color(0xFFD9D4D2),
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasRageResistance) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF736A63), Color(0xFF595048)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFD9D4D2), width: 1),
                                ),
                                child: const Text(
                                  '🛡️ 분노 내성 +10%',
                                  style: TextStyle(
                                    color: Color(0xFFD9D4D2),
                                    fontFamily: 'JoseonGulim',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatChip('Lv.${student['level']}', Icons.star),
                            const SizedBox(width: 8),
                            _buildStatChip('${student['exp']} EXP', Icons.trending_up),
                            if (totalQuestions > 0) ...[
                              const SizedBox(width: 8),
                              _buildStatChip('${accuracy.toStringAsFixed(1)}%', Icons.check_circle),
                            ],
                          ],
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

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF736A63)),
          const SizedBox(width: 4),
          Text(
            text,
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
}
