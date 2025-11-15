import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

class PasswordSetupScreen extends StatefulWidget {
  final String studentId;
  final String username;

  const PasswordSetupScreen({
    super.key,
    required this.studentId,
    required this.username,
  });

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _setPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = '비밀번호를 입력해주세요');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다');
      return;
    }

    if (_passwordController.text.length < 4) {
      setState(() => _errorMessage = '비밀번호는 최소 4자 이상이어야 합니다');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.setPassword(widget.studentId, _passwordController.text);
      
      if (response['success'] == true && mounted) {
        final provider = Provider.of<GameProvider>(context, listen: false);
        provider.setCurrentStudent(response['student']);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(initialStudent: provider.currentStudent!),
          ),
        );
      } else {
        setState(() => _errorMessage = response['message'] ?? '비밀번호 설정 실패');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '비밀번호 설정 실패: $e');
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
                '비밀번호 설정',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.username}님, 환영합니다!',
                style: const TextStyle(
                  color: Color(0xFF736A63),
                  fontFamily: 'JoseonGulim',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '비밀번호 (최소 4자)',
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
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
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
                      onSubmitted: (_) => _setPassword(),
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
                        onPressed: _isLoading ? null : _setPassword,
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
                    ),
                  ],
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
