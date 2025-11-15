import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';
import 'profile_complete_screen.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _showExtraFields = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_nameController.text.isEmpty) {
      setState(() => _errorMessage = '이름을 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      await provider.studentLogin(
        _nameController.text,
        birthDate: _birthDateController.text.isNotEmpty ? _birthDateController.text : null,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );

      if (mounted && provider.currentStudent != null) {
        if (provider.currentStudent!.isProfileComplete == false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileCompleteScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialStudent: provider.currentStudent!),
            ),
          );
        }
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('동명이인')) {
        setState(() {
          _showExtraFields = true;
          _errorMessage = '동명이인이 있습니다. 생년월일 또는 휴대폰 번호를 입력해주세요.';
        });
      } else {
        setState(() => _errorMessage = '로그인 실패: $errorMsg');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '허태훈의 분노 던전',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '이름',
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
                      onSubmitted: (_) => _showExtraFields ? null : _login(),
                    ),
                    if (_showExtraFields) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _birthDateController,
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                        ),
                        decoration: InputDecoration(
                          labelText: '생년월일 (예: 20000101)',
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                        ),
                        decoration: InputDecoration(
                          labelText: '휴대폰 번호 (예: 010-1234-5678)',
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
                        onSubmitted: (_) => _login(),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _showExtraFields ? const Color(0xFFD9D4D2) : Colors.red,
                          fontFamily: 'JoseonGulim',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
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
                                '로그인',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'JoseonGulim',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                ),
                child: const Text(
                  '관리자 로그인 →',
                  style: TextStyle(
                    color: Color(0xFF736A63),
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
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
