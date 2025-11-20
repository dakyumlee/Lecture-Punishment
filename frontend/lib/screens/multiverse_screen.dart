import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class MultiverseScreen extends StatefulWidget {
  final Student student;
  const MultiverseScreen({super.key, required this.student});

  @override
  State<MultiverseScreen> createState() => _MultiverseScreenState();
}

class _MultiverseScreenState extends State<MultiverseScreen> {
  List<Map<String, dynamic>> _universes = [];
  Map<String, dynamic>? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final universes = await ApiService.getMultiverseUniverses(widget.student.id);
      final progress = await ApiService.getMultiverseProgress(widget.student.id);
      setState(() {
        _universes = universes;
        _progress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _obtainFragment(String multiverseId) async {
    try {
      final result = await ApiService.obtainSoulFragment(
        studentId: widget.student.id,
        multiverseInstructorId: multiverseId,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${result['fragmentName']} 획득!',
                style: const TextStyle(fontFamily: 'JoseonGulim'),
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          _loadData();

          if (result['canUnlockEnding'] == true) {
            _showEndingDialog();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('영혼 조각 획득 실패', style: TextStyle(fontFamily: 'JoseonGulim')),
              backgroundColor: Color(0xFFFF5722),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e', style: const TextStyle(fontFamily: 'JoseonGulim')),
            backgroundColor: const Color(0xFFFF5722),
          ),
        );
      }
    }
  }

  Future<void> _unlockEnding() async {
    try {
      final result = await ApiService.unlockSpecialEnding(widget.student.id);
      if (mounted && result['success'] == true) {
        Navigator.pop(context);
        _showFinalEndingDialog(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  void _showEndingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🌟 특별 엔딩 해금 가능!',
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '모든 영혼 조각을 모았습니다!\n특별 엔딩을 해금하시겠습니까?',
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에', style: TextStyle(color: Color(0xFF736A63))),
          ),
          ElevatedButton(
            onPressed: _unlockEnding,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('해금하기', style: TextStyle(fontFamily: 'JoseonGulim')),
          ),
        ],
      ),
    );
  }

  void _showFinalEndingDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          result['title'] ?? '특별 엔딩',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'JoseonGulim',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              result['message'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '+${result['rewards']?['exp'] ?? 0} EXP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '+${result['rewards']?['points'] ?? 0} 포인트',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '칭호: ${result['rewards']?['title'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JoseonGulim',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontFamily: 'JoseonGulim',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '🌌 허태훈 멀티버스',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : Column(
              children: [
                _buildProgressHeader(),
                Expanded(child: _buildUniverseList()),
              ],
            ),
    );
  }

  Widget _buildProgressHeader() {
    final collected = _progress?['collectedFragments'] ?? 0;
    final total = _progress?['totalUniverses'] ?? 3;
    final canUnlock = _progress?['canUnlockEnding'] ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '허태훈의 분노가 쪼개져\n여러 세계가 생겼다...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 12),
              Text(
                '영혼 조각: $collected / $total',
                style: const TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (canUnlock) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _unlockEnding,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                '🌟 특별 엔딩 해금하기',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'JoseonGulim',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUniverseList() {
    if (_universes.isEmpty) {
      return const Center(
        child: Text(
          '멀티버스를 불러올 수 없습니다',
          style: TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _universes.length,
      itemBuilder: (context, index) => _buildUniverseCard(_universes[index]),
    );
  }

  Widget _buildUniverseCard(Map<String, dynamic> universe) {
    final name = universe['name'] ?? '';
    final description = universe['description'] ?? '';
    final emoji = universe['avatarEmoji'] ?? '🤖';
    final trait = universe['personalityTrait'] ?? '';
    final ability = universe['specialAbility'] ?? '';
    final isUnlocked = universe['isUnlocked'] ?? false;
    final hasFragment = universe['hasFragment'] ?? false;
    final unlockCondition = universe['unlockCondition'] ?? '';
    final diffMultiplier = universe['difficultyMultiplier'] ?? 1.0;
    final rewardMultiplier = universe['rewardMultiplier'] ?? 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFragment ? const Color(0xFF4CAF50) : const Color(0xFF736A63),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF736A63).withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trait,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontFamily: 'JoseonGulim',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasFragment)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: Color(0xFFFF5722), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            ability,
                            style: const TextStyle(
                              color: Color(0xFFFF5722),
                              fontFamily: 'JoseonGulim',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            '난이도: ',
                            style: TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '×${diffMultiplier.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            '보상: ',
                            style: TextStyle(
                              color: Color(0xFF736A63),
                              fontFamily: 'JoseonGulim',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '×${rewardMultiplier.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontFamily: 'JoseonGulim',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUnlocked && !hasFragment
                        ? () => _obtainFragment(universe['id'])
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasFragment
                          ? const Color(0xFF4CAF50)
                          : isUnlocked
                              ? const Color(0xFFFF5722)
                              : const Color(0xFF736A63),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: const Color(0xFF736A63),
                    ),
                    child: Text(
                      hasFragment
                          ? '✓ 영혼 조각 획득 완료'
                          : isUnlocked
                              ? '영혼 조각 획득하기'
                              : '🔒 $unlockCondition',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
