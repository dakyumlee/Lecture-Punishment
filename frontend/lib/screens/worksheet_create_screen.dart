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
    
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF 파일을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.createWorksheet(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        file: _selectedFile,
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
        backgroundColor: const Color(0xFF00010D),
        title: const Text(
          '문제지 생성',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
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
                  labelStyle: const TextStyle(color: Color(0xFF736A63)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _categoryController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                decoration: InputDecoration(
                  labelText: '카테고리 (예: 프로그래밍, 자료구조, 네트워크)',
                  labelStyle: const TextStyle(color: Color(0xFF736A63)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF595048)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '카테고리를 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
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
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF595048)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'PDF 문제지 파일',
                      style: TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontSize: 16,
                        fontFamily: 'JoseonGulim',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('PDF 선택'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF595048),
                        foregroundColor: const Color(0xFFD9D4D2),
                      ),
                    ),
                    if (_fileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '선택된 파일: $_fileName',
                        style: const TextStyle(
                          color: Color(0xFF736A63),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
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
                        '문제지 생성',
                        style: TextStyle(
                          fontSize: 16,
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
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
