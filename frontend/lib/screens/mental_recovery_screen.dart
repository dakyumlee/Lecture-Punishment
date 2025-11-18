import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class MentalRecoveryScreen extends StatefulWidget {
  final Student student;
  
  const MentalRecoveryScreen({super.key, required this.student});
  
  @override
  State<MentalRecoveryScreen> createState() => _MentalRecoveryScreenState();
}

class _MentalRecoveryScreenState extends State<MentalRecoveryScreen> {
  Map<String, dynamic>? _mission;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadMission();
  }

  Future<void> _loadMission() async {
    try {
      final mission = await ApiService.getRandomMentalMission('self_praise');
      setState(() {
        _mission = mission;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null || _mission == null) return;
    
    try {
      final result = await ApiService.completeMentalMission(
        studentId: widget.student.id,
        missionId: _mission!['id'],
        answer: _selectedAnswer!,
      );
      
      setState(() {
        _isCorrect = result['success'] == true;
        _showResult = true;
      });
      
      if (_isCorrect) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error submitting answer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '멘탈 회복 미션',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _mission == null
              ? _buildNoMission()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMissionCard(),
                      const SizedBox(height: 24),
                      if (!_showResult) _buildAnswerSection(),
                      if (_showResult) _buildResult(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoMission() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info, size: 80, color: Color(0xFF595048)),
          const SizedBox(height: 24),
          const Text(
            '현재 이용 가능한 미션이 없습니다',
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
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _mission!['title'] ?? '멘탈 회복 미션',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_mission!['description'] != null)
            Text(
              _mission!['description'],
              style: const TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _mission!['questionText'] ?? '',
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.healing, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                '회복량: +${_mission!['recoveryAmount'] ?? 20}',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontFamily: 'JoseonGulim',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '답변을 입력하세요',
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _selectedAnswer = value),
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
          decoration: InputDecoration(
            hintText: '긍정적인 답변을 입력하세요',
            hintStyle: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
            ),
            filled: true,
            fillColor: const Color(0xFF0D0D0D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF736A63)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _selectedAnswer != null && _selectedAnswer!.isNotEmpty
              ? _submitAnswer
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            '완료',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'JoseonGulim',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            _isCorrect ? '멘탈 회복 성공!' : '다시 시도해보세요',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'JoseonGulim',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isCorrect)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                '잠시 후 자동으로 돌아갑니다...',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'JoseonGulim',
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
