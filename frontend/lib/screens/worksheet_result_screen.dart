import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WorksheetResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final String worksheetTitle;
  
  const WorksheetResultScreen({
    super.key,
    required this.result,
    required this.worksheetTitle,
  });

  @override
  State<WorksheetResultScreen> createState() => _WorksheetResultScreenState();
}

class _WorksheetResultScreenState extends State<WorksheetResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _aiComment;
  bool _isLoadingComment = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _loadAIComment();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAIComment() async {
    final percentage = widget.result['percentage'] ?? 0;
    final correctCount = widget.result['correctCount'] ?? 0;
    final wrongCount = widget.result['wrongCount'] ?? 0;
    final totalQuestions = correctCount + wrongCount;
    
    try {
      final response = await ApiService.submitQuizResult(
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        subject: widget.worksheetTitle,
      );
      
      setState(() {
        _aiComment = response['comment'];
        _isLoadingComment = false;
      });
    } catch (e) {
      setState(() {
        _aiComment = _getDefaultComment(percentage);
        _isLoadingComment = false;
      });
    }
  }

  String _getDefaultComment(int percentage) {
    if (percentage == 100) return "완벽하다! 이게 바로 프로지!";
    if (percentage >= 90) return "잘했어. 이 정도면 인정한다.";
    if (percentage >= 80) return "괜찮은데? 계속 유지해봐.";
    if (percentage >= 70) return "그냥저냥이네. 더 노력해.";
    if (percentage >= 60) return "이 정도로 만족하냐?";
    if (percentage >= 50) return "반타작이면 부끄러운 줄 알아야지.";
    return "너 진짜... 복습 10번 해.";
  }

  Color _getScoreColor(int percentage) {
    if (percentage == 100) return const Color(0xFF4CAF50);
    if (percentage >= 80) return const Color(0xFF8BC34A);
    if (percentage >= 60) return const Color(0xFFFFEB3B);
    if (percentage >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }

  String _getScoreEmoji(int percentage) {
    if (percentage == 100) return '🎉';
    if (percentage >= 90) return '😊';
    if (percentage >= 80) return '👍';
    if (percentage >= 70) return '🤔';
    if (percentage >= 60) return '😐';
    if (percentage >= 50) return '😰';
    if (percentage >= 40) return '😭';
    return '💀';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.result['percentage'] ?? 0;
    final totalScore = widget.result['totalScore'] ?? 0;
    final maxScore = widget.result['maxScore'] ?? 0;
    final correctCount = widget.result['correctCount'] ?? 0;
    final wrongCount = widget.result['wrongCount'] ?? 0;
    final expGained = widget.result['expGained'] ?? 0;
    final pointsGained = widget.result['pointsGained'] ?? 0;
    final leveledUp = widget.result['leveledUp'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '채점 결과',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getScoreColor(percentage).withOpacity(0.3),
                        const Color(0xFF00010D),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.worksheetTitle,
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getScoreEmoji(percentage),
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$percentage',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(percentage),
                              fontFamily: 'JoseonGulim',
                              height: 1.0,
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(percentage),
                              fontFamily: 'JoseonGulim',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalScore / $maxScore점',
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF595048), width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '😤 허태훈의 한마디',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF736A63),
                                fontFamily: 'JoseonGulim',
                              ),
                            ),
                            const SizedBox(height: 12),
                            _isLoadingComment
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFD9D4D2),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _aiComment ?? _getDefaultComment(percentage),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFD9D4D2),
                                      fontFamily: 'JoseonGulim',
                                      fontWeight: FontWeight.bold,
                                      height: 1.5,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '✅',
                              '정답',
                              '$correctCount',
                              Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              '❌',
                              '오답',
                              '$wrongCount',
                              Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF595048),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '🎁 획득 보상',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF736A63),
                                fontFamily: 'JoseonGulim',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildRewardItem('⚡', 'EXP', expGained),
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: const Color(0xFF736A63),
                                ),
                                _buildRewardItem('💰', '포인트', pointsGained),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (leveledUp) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '🎉 레벨 업! 🎉',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lv.${widget.result['newLevel']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF595048),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '홈으로',
                            style: TextStyle(
                              fontFamily: 'JoseonGulim',
                              fontSize: 20,
                              color: Color(0xFFD9D4D2),
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: 'JoseonGulim',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String emoji, String label, int value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
      ],
    );
  }
}
