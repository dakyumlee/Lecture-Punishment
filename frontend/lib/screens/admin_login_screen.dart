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
      final result = await ApiService.adminLogin(
        _usernameController.text,
        _passwordController.text,
      );
      if (mounted && result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = '로그인 실패: 아이디 또는 비밀번호를 확인하세요');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
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
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '아이디',
                        labelStyle: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D0D0D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF595048)),
                        enabledBorder: OutlineInputBorder(
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF736A63)),
                    ),
                    const SizedBox(height: 16),
                      controller: _passwordController,
                      obscureText: true,
                        labelText: '비밀번호',
                      onSubmitted: (_) => _login(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
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
                                  fontFamily: 'JoseonGulim',
                                  fontSize: 18,
                              ),
                  ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '← 뒤로 가기',
                  style: TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                  ),
            ],
        ),
      ),
    );
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
