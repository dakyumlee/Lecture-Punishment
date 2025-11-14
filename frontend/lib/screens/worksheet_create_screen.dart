import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class WorksheetCreateScreen extends StatefulWidget {
  const WorksheetCreateScreen({super.key});

  @override
  State<WorksheetCreateScreen> createState() => _WorksheetCreateScreenState();
}

class _WorksheetCreateScreenState extends State<WorksheetCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  PlatformFile? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = result.files.first.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 선택 실패: $e')),
      );
    }
  }

  Future<void> _createWorksheet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.createWorksheet(
        title: _titleController.text,
        description: _descriptionController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문제지가 생성되었습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '문제지 생성',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                decoration: InputDecoration(
                  labelText: '제목',
                  labelStyle: const TextStyle(color: Color(0xFF736A63)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '설명',
                  labelStyle: const TextStyle(color: Color(0xFF736A63)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createWorksheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595048),
                  foregroundColor: const Color(0xFFD9D4D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFD9D4D2))
                    : const Text(
                        '생성',
                        style: TextStyle(fontSize: 18, fontFamily: 'JoseonGulim'),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
