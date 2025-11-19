import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signup() async {
    if (_nameController.text.isEmpty) {
      setState(() => _errorMessage = '이름을 입력해주세요');
      return;
    }

    if (_birthDateController.text.isEmpty) {
      setState(() => _errorMessage = '생년월일을 입력해주세요');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = '비밀번호를 입력해주세요');
      return;
    }

    if (_passwordController.text.length < 4) {
      setState(() => _errorMessage = '비밀번호는 최소 4자 이상이어야 합니다');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.signup(
        _nameController.text,
        _birthDateController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (response['success'] == true) {
          final studentId = response['studentId'];
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF0D0D0D),
              title: const Text(
                '회원가입 완료!',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '당신의 학생ID는',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF595048),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      studentId,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '입니다!',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '로그인할 때 사용하세요.',
                    style: TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF595048),
                      foregroundColor: const Color(0xFFD9D4D2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '로그인하러 가기',
                      style: TextStyle(
                        fontFamily: 'JoseonGulim',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          setState(() => _errorMessage = response['message'] ?? '회원가입 실패');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '회원가입 실패: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF595048),
              onPrimary: Color(0xFFD9D4D2),
              surface: Color(0xFF0D0D0D),
              onSurface: Color(0xFFD9D4D2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00010D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD9D4D2)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '회원가입',
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
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: _selectDate,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                      ),
                      decoration: InputDecoration(
                        labelText: '생년월일',
                        hintText: 'YYYY-MM-DD',
                        hintStyle: const TextStyle(
                          color: Color(0xFF595048),
                          fontFamily: 'JoseonGulim',
                        ),
                        labelStyle: const TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF736A63),
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
                      onSubmitted: (_) => _signup(),
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
                        onPressed: _isLoading ? null : _signup,
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
                                '회원가입',
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
    _nameController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
