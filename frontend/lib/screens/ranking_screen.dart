import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}
class _RankingScreenState extends State<RankingScreen> {
  final ApiService _apiService = ApiService();
  List<Student> _topStudents = [];
  bool _isLoading = true;
  void initState() {
    super.initState();
    _loadRankings();
  }
  Future<void> _loadRankings() async {
    try {
      final students = await _apiService.getTopStudents();
      setState(() {
        _topStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('랭킹 로드 실패: $e')),
        );
      }
    }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('클래스 랭킹'),
        backgroundColor: AppTheme.secondaryDark,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.primaryDark,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.lightGray),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _topStudents.length,
                itemBuilder: (context, index) {
                  final student = _topStudents[index];
                  final rank = index + 1;
                  final hasRageResistance = rank <= 10;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.secondaryDark,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          color: rank <= 3 ? Colors.amber : AppTheme.accentBrown,
                          alignment: Alignment.center,
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              color: AppTheme.lightGray,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.displayName,
                                style: const TextStyle(
                                  color: AppTheme.lightGray,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                                'Lv.${student.level} | EXP ${student.exp}',
                                  color: AppTheme.accentBrown,
                                  fontSize: 14,
                            ],
                        if (hasRageResistance)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            color: Colors.red[900],
                            child: const Text(
                              '분노 내성 +10%',
                              style: TextStyle(
                                color: AppTheme.lightGray,
                                fontSize: 12,
                      ],
                    ),
                  );
                },
              ),
    );
