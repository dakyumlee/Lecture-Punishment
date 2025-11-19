import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<dynamic> _ranking = [];
  bool _isLoading = true;
  String _sortBy = 'points';

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getRanking(sortBy: _sortBy, limit: 10);
      setState(() {
        _ranking = result['ranking'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _changeSortBy(String sortBy) {
    setState(() => _sortBy = sortBy);
    _loadRanking();
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
      ),
      body: Column(
        children: [
          _buildSortButtons(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
                : _ranking.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRanking,
                        color: const Color(0xFFD9D4D2),
                        backgroundColor: const Color(0xFF595048),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _ranking.length,
                          itemBuilder: (context, index) => _buildRankCard(_ranking[index], index),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildSortButton('포인트', 'points')),
          const SizedBox(width: 8),
          Expanded(child: _buildSortButton('레벨', 'level')),
          const SizedBox(width: 8),
          Expanded(child: _buildSortButton('정답률', 'correctRate')),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value) {
    final isSelected = _sortBy == value;
    return ElevatedButton(
      onPressed: () => _changeSortBy(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF595048),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
          fontFamily: 'JoseonGulim',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> student, int index) {
    final rank = student['rank'] ?? (index + 1);
    final name = student['displayName'] ?? '익명';
    final level = student['level'] ?? 0;
    final points = student['points'] ?? 0;
    final correctRate = student['correctRate'] ?? 0.0;
    final hasBadge = student['hasRageResistanceBadge'] ?? false;

    Color rankColor;
    IconData rankIcon;
    
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = const Color(0xFF736A63);
      rankIcon = Icons.star;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
        border: rank <= 3
            ? Border.all(color: rankColor, width: 2)
            : null,
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: rankColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(rankIcon, color: rankColor, size: 20),
                Text(
                  '$rank',
                  style: TextStyle(
                    color: rankColor,
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                        name,
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '분노 내성 +10%',
                          style: TextStyle(
                            color: Colors.white,
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
                    _buildStatChip('Lv.$level', Icons.star),
                    const SizedBox(width: 8),
                    _buildStatChip('${points}P', Icons.monetization_on),
                    const SizedBox(width: 8),
                    _buildStatChip('${correctRate.toStringAsFixed(1)}%', Icons.check_circle),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Color(0xFF595048)),
          const SizedBox(height: 24),
          const Text(
            '아직 랭킹이 없습니다',
            style: TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadRanking,
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
}
