import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/student.dart';
import '../widgets/expression_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  final Student student;
  const ProfileEditScreen({super.key, required this.student});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _phoneController;
  late TextEditingController _studentIdController;
  late String _currentExpression;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.student.displayName);
    _birthDateController = TextEditingController(text: widget.student.birthDate ?? '');
    _phoneController = TextEditingController(text: widget.student.phoneNumber ?? '');
    _studentIdController = TextEditingController(text: widget.student.studentIdNumber ?? '');
    _currentExpression = widget.student.characterExpression ?? '😊';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final profileData = {
        'displayName': _displayNameController.text,
        'birthDate': _birthDateController.text.isNotEmpty ? _birthDateController.text : '',
        'phoneNumber': _phoneController.text.isNotEmpty ? _phoneController.text : '',
        'studentIdNumber': _studentIdController.text.isNotEmpty ? _studentIdController.text : '',
      };

      await ApiService.updateProfile(widget.student.id, profileData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업데이트 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showExpressionPicker() {
    showDialog(
      context: context,
      builder: (context) => ExpressionPicker(
        studentId: widget.student.id,
        currentExpression: _currentExpression,
        onExpressionChanged: (newExpression) {
          setState(() => _currentExpression = newExpression);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00010D),
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD9D4D2)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _showExpressionPicker,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF595048),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          _currentExpression,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFFD9D4D2),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '표정을 클릭하여 변경',
                style: TextStyle(
                  color: Color(0xFF736A63),
                  fontFamily: 'JoseonGulim',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _displayNameController,
              label: '표시 이름',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _birthDateController,
              label: '생년월일 (예: 2000-01-01)',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: '휴대폰 번호 (예: 010-1234-5678)',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _studentIdController,
              label: '학번',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
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
                        '저장',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFFD9D4D2),
        fontFamily: 'JoseonGulim',
      ),
      decoration: InputDecoration(
        labelText: label,
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
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }
}
