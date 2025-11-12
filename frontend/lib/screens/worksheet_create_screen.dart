import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorksheetCreateScreen extends StatefulWidget {
  const WorksheetCreateScreen({super.key});

  @override
  State<WorksheetCreateScreen> createState() => _WorksheetCreateScreenState();
}

class _WorksheetCreateScreenState extends State<WorksheetCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  
  String _selectedCategory = '프로그래밍';
  int _difficultyLevel = 3;
  bool _isLoading = false;
  
  final List<String> _categories = ['프로그래밍', '자료구조', '데이터베이스', '네트워크', '운영체제'];

  Future<void> _createWorksheet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/worksheets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'subject': _subjectController.text,
          'category': _selectedCategory,
          'difficultyLevel': _difficultyLevel,
        }),
      );

      if (response.statusCode == 200) {
        final worksheet = jsonDecode(response.body);
        if (mounted) {
          Navigator.pop(context, worksheet);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문제지가 생성되었습니다!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
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
        title: const Text('문제지 생성', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                decoration: InputDecoration(
                  labelText: '문제지 제목',
                  labelStyle: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF595048))),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD9D4D2))),
                ),
                validator: (v) => v?.isEmpty ?? true ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                decoration: InputDecoration(
                  labelText: '과목명',
                  labelStyle: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF595048))),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD9D4D2))),
                ),
                validator: (v) => v?.isEmpty ?? true ? '과목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF595048),
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                decoration: InputDecoration(
                  labelText: '카테고리',
                  labelStyle: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF595048))),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD9D4D2))),
                ),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '설명',
                  labelStyle: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF595048))),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD9D4D2))),
                ),
              ),
              const SizedBox(height: 16),
              Text('난이도: $_difficultyLevel', style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim', fontSize: 16)),
              Slider(
                value: _difficultyLevel.toDouble(),
                min: 1, max: 5, divisions: 4,
                activeColor: const Color(0xFFD9D4D2),
                inactiveColor: const Color(0xFF595048),
                onChanged: (val) => setState(() => _difficultyLevel = val.toInt()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createWorksheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595048),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFD9D4D2))
                    : const Text('문제지 생성', style: TextStyle(fontFamily: 'JoseonGulim', fontSize: 18, color: Color(0xFFD9D4D2))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
