import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../services/api_service.dart';

class QuizCreateScreen extends StatefulWidget {
  @override
  _QuizCreateScreenState createState() => _QuizCreateScreenState();
}

class _QuizCreateScreenState extends State<QuizCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedMethod = 'manual';
  String? _selectedCategory;
  String? _selectedGroup;
  
  List<dynamic> _groups = [];
  List<String> _categories = ['HTML/CSS', 'JavaScript', 'Java', 'Spring', 'Database', '기타'];
  
  List<Map<String, dynamic>> _questions = [];
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  String? _ocrResult;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await ApiService.getAllGroups();
      setState(() {
        _groups = groups;
      });
    } catch (e) {
      print('그룹 로딩 실패: $e');
    }
  }

  Future<void> _uploadPdfAndExtract() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final bytes = result.files.first.bytes!;
        final fileName = result.files.first.name;

        final response = await ApiService.extractQuestionsFromPdf(
          fileBytes: bytes,
          fileName: fileName,
        );

        if (response['success'] == true) {
          setState(() {
            _questions = List<Map<String, dynamic>>.from(response['questions']);
            _ocrResult = '${_questions.length}개의 문제를 추출했습니다!';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ OCR 성공: ${_questions.length}개 문제 추출')),
          );
        } else {
          throw Exception(response['error'] ?? 'OCR 실패');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ OCR 실패: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addManualQuestion() {
    setState(() {
      _questions.add({
        'questionNumber': _questions.length + 1,
        'questionType': 'multiple_choice',
        'questionText': '',
        'optionA': '',
        'optionB': '',
        'optionC': '',
        'optionD': '',
        'correctAnswer': '1',
        'points': 10,
      });
    });
  }

  Future<void> _saveQuestions() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제를 추가해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (var question in _questions) {
        await ApiService.createQuiz(
          category: _selectedCategory ?? '기타',
          groupId: _selectedGroup,
          questionData: question,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${_questions.length}개 문제 저장 완료!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 저장 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00010D),
      appBar: AppBar(
        title: Text('문제 출제', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: Color(0xFF595048),
        iconTheme: IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMethodSelector(),
                    SizedBox(height: 30),
                    _buildCategorySelector(),
                    SizedBox(height: 20),
                    _buildGroupSelector(),
                    SizedBox(height: 30),
                    if (_selectedMethod == 'pdf') _buildPdfUploader(),
                    if (_selectedMethod == 'manual') _buildManualQuestions(),
                    SizedBox(height: 30),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '출제 방식 선택',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildMethodButton('PDF OCR', 'pdf'),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildMethodButton('직접 작성', 'manual'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(String label, String method) {
    bool isSelected = _selectedMethod == method;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedMethod = method;
          _questions.clear();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF736A63) : Color(0xFF0D0D0D),
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Color(0xFFD9D4D2) : Color(0xFF595048),
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 16,
          fontFamily: 'JoseonGulim',
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리 선택',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 18,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Color(0xFF595048),
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            hint: Text('카테고리를 선택하세요', style: TextStyle(color: Color(0xFF736A63))),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '대상 그룹 선택 (선택사항)',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 18,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedGroup,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Color(0xFF595048),
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            hint: Text('전체 학생 (선택안함)', style: TextStyle(color: Color(0xFF736A63))),
            items: _groups.map<DropdownMenuItem<String>>((group) {
              return DropdownMenuItem(
                value: group['id'],
                child: Text(group['groupName'] ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGroup = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPdfUploader() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 80, color: Color(0xFFD9D4D2)),
          SizedBox(height: 20),
          Text(
            'PDF 파일을 업로드하면\nAI가 자동으로 문제를 추출합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 18,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _uploadPdfAndExtract,
            icon: Icon(Icons.file_upload),
            label: Text('PDF 업로드', style: TextStyle(fontSize: 18, fontFamily: 'JoseonGulim')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF736A63),
              foregroundColor: Color(0xFFD9D4D2),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
          if (_ocrResult != null) ...[
            SizedBox(height: 20),
            Text(
              _ocrResult!,
              style: TextStyle(
                color: Color(0xFFD9D4D2),
                fontSize: 16,
                fontFamily: 'JoseonGulim',
              ),
            ),
          ],
          if (_questions.isNotEmpty) ...[
            SizedBox(height: 20),
            ..._questions.asMap().entries.map((entry) {
              int index = entry.key;
              var q = entry.value;
              return _buildQuestionPreview(index, q);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildManualQuestions() {
    return Column(
      children: [
        ..._questions.asMap().entries.map((entry) {
          int index = entry.key;
          return _buildQuestionEditor(index);
        }).toList(),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _addManualQuestion,
          icon: Icon(Icons.add),
          label: Text('문제 추가', style: TextStyle(fontSize: 18, fontFamily: 'JoseonGulim')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF595048),
            foregroundColor: Color(0xFFD9D4D2),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionEditor(int index) {
    var question = _questions[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 ${index + 1}',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JoseonGulim',
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Color(0xFFD9D4D2)),
                onPressed: () {
                  setState(() {
                    _questions.removeAt(index);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildTextField('문제', question, 'questionText', maxLines: 3),
          SizedBox(height: 15),
          _buildTextField('보기 1', question, 'optionA'),
          _buildTextField('보기 2', question, 'optionB'),
          _buildTextField('보기 3', question, 'optionC'),
          _buildTextField('보기 4', question, 'optionD'),
          SizedBox(height: 15),
          Text(
            '정답',
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: question['correctAnswer'],
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            dropdownColor: Color(0xFF0D0D0D),
            style: TextStyle(color: Color(0xFFD9D4D2)),
            items: ['1', '2', '3', '4'].map((answer) {
              return DropdownMenuItem(value: answer, child: Text('보기 $answer'));
            }).toList(),
            onChanged: (value) {
              setState(() {
                question['correctAnswer'] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Map<String, dynamic> question, String field, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: question[field],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF736A63)),
          filled: true,
          fillColor: Color(0xFF0D0D0D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
        maxLines: maxLines,
        onChanged: (value) {
          question[field] = value;
        },
      ),
    );
  }

  Widget _buildQuestionPreview(int index, Map<String, dynamic> question) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${question['questionText']}',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 16,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 10),
          if (question['optionA'] != null && question['optionA'].toString().isNotEmpty) ...[
            Text('1) ${question['optionA']}', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
            Text('2) ${question['optionB']}', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
            Text('3) ${question['optionC']}', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
            Text('4) ${question['optionD']}', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _questions.isEmpty ? null : _saveQuestions,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF736A63),
          foregroundColor: Color(0xFFD9D4D2),
          padding: EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          '문제 저장 (${_questions.length}개)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'JoseonGulim',
          ),
        ),
      ),
    );
  }
}
