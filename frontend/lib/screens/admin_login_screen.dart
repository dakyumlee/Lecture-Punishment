import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ApiService.adminLogin(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = '로그인 실패');
      }
    } catch (e) {
      setState(() => _errorMessage = '오류: $e');
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
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Color(0xFFD9D4D2),
              ),
              const SizedBox(height: 24),
              const Text(
                '관리자 로그인',
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
                      controller: _usernameController,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: InputDecoration(
                        labelText: '아이디',
                        labelStyle: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF595048)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFD9D4D2)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF595048)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFD9D4D2)),
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
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF595048),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFFD9D4D2))
                            : const Text(
                                '로그인',
                                style: TextStyle(
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 18,
                                  color: Color(0xFFD9D4D2),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '← 뒤로 가기',
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
