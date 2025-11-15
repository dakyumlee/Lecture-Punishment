import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/student.dart';
import 'profile_edit_screen.dart';
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}
class _MyPageScreenState extends State<MyPageScreen> {
  Map<String, dynamic>? _myPageData;
  bool _isLoading = true;
  void initState() {
    super.initState();
    _loadMyPageData();
  }
  Future<void> _loadMyPageData() async {
    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      final data = await provider.getMyPageData();
      setState(() {
        _myPageData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    }
  Future<void> _navigateToEditProfile(Student student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(student: student),
      ),
    );
    if (result == true) {
      _loadMyPageData();
  Widget build(BuildContext context) {
    final student = Provider.of<GameProvider>(context).currentStudent;
    if (student == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF00010D),
        body: Center(
          child: Text(
            '로그인이 필요합니다',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
            ),
          ),
        ),
      );
    if (_isLoading) {
          child: CircularProgressIndicator(
            color: Color(0xFFD9D4D2),
    final level = _myPageData?['level'] ?? student.level;
    final exp = _myPageData?['exp'] ?? student.exp;
    final points = _myPageData?['points'] ?? student.points;
    final totalCorrect = _myPageData?['totalCorrect'] ?? 0;
    final totalWrong = _myPageData?['totalWrong'] ?? 0;
    final totalAttempts = totalCorrect + totalWrong;
    final accuracy = totalAttempts > 0 ? (totalCorrect / totalAttempts * 100).toStringAsFixed(1) : '0.0';
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00010D),
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD9D4D2)),
          onPressed: () => Navigator.pop(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF595048),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Center(
                        child: Text(
                          student.characterExpression ?? '😊',
                          style: const TextStyle(fontSize: 60),
                        ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.displayName,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                    const SizedBox(height: 8),
                      '@${student.username}',
                        color: Color(0xFF736A63),
                        fontSize: 16,
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                title: '레벨 & 경험치',
                children: [
                  _buildInfoRow('레벨', 'Lv. $level'),
                  _buildInfoRow('경험치', '$exp EXP'),
                  _buildInfoRow('포인트', '$points P'),
                ],
              const SizedBox(height: 16),
                title: '학습 통계',
                  _buildInfoRow('정답', '$totalCorrect'),
                  _buildInfoRow('오답', '$totalWrong'),
                  _buildInfoRow('정확도', '$accuracy%'),
                title: '프로필 정보',
                  if (student.birthDate != null)
                    _buildInfoRow('생년월일', student.birthDate!),
                  if (student.phoneNumber != null)
                    _buildInfoRow('휴대폰', student.phoneNumber!),
                  if (student.studentIdNumber != null)
                    _buildInfoRow('학번', student.studentIdNumber!),
                  if (student.birthDate == null && student.phoneNumber == null && student.studentIdNumber == null)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '추가 정보가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToEditProfile(student),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595048),
                    foregroundColor: const Color(0xFFD9D4D2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '프로필 편집',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'JoseonGulim',
            ],
  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF595048)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
          const SizedBox(height: 12),
          ...children,
        ],
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
            label,
              color: Color(0xFF736A63),
              fontSize: 16,
            value,
