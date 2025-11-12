import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력하세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      await provider.loginStudent(_usernameController.text);

      if (mounted && provider.currentStudent != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(student: provider.currentStudent!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '허태훈의',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 32,
                ),
              ),
              const Text(
                '분노 던전',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '안 외웠으면 뒤진다',
                style: TextStyle(
                  color: Color(0xFF595048),
                  fontFamily: 'JoseonGulim',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 64),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
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
                  onSubmitted: (_) => _login(),
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SizedBox(
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
                            '입장하기',
                            style: TextStyle(
                              fontFamily: 'JoseonGulim',
                              fontSize: 18,
                              color: Color(0xFFD9D4D2),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  '관리자 로그인',
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
    super.dispose();
  }
}
