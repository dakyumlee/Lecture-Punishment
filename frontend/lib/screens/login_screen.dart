import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_studentIdController.text.isEmpty) {
      setState(() => _errorMessage = '학생ID를 입력해주세요');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = '비밀번호를 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.login(
        _studentIdController.text,
        _passwordController.text,
      );
      
      if (response['success'] == true) {
        final provider = Provider.of<GameProvider>(context, listen: false);
        provider.setCurrentStudent(response['student']);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialStudent: provider.currentStudent!),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = response['message'] ?? '로그인 실패');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '로그인 실패: $e');
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
                      controller: _studentIdController,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '학생ID (예: DGK001)',
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
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '비밀번호',
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
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
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
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                ),
                child: const Text(
                  '회원가입 →',
                  style: TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
