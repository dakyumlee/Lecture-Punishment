import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});
  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _complete() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      
      if (provider.currentStudent == null) {
        throw Exception('학생 정보가 없습니다');
      }

      final profileData = <String, String>{};
      
      if (_birthDateController.text.isNotEmpty) {
        profileData['birthDate'] = _birthDateController.text;
      }
      if (_phoneController.text.isNotEmpty) {
        profileData['phoneNumber'] = _phoneController.text;
      }
      if (_studentIdController.text.isNotEmpty) {
        profileData['studentIdNumber'] = _studentIdController.text;
      }

      await provider.completeProfile(provider.currentStudent!.id, profileData);
      
      if (mounted && provider.currentStudent != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(initialStudent: provider.currentStudent!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 완성 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '프로필 완성',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '추가 정보를 입력해주세요',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _birthDateController,
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                decoration: InputDecoration(
                  labelText: '생년월일 (YYYYMMDD)',
                  labelStyle: const TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF736A63)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                decoration: InputDecoration(
                  labelText: '전화번호',
                  labelStyle: const TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF736A63)),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _studentIdController,
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                decoration: InputDecoration(
                  labelText: '학번',
                  labelStyle: const TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF736A63)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _complete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595048),
                  foregroundColor: const Color(0xFFD9D4D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD9D4D2),
                        ),
                      )
                    : const Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'JoseonGulim',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }
}