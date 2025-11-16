import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';

class WorksheetCreateScreen extends StatefulWidget {
  @override
  _WorksheetCreateScreenState createState() => _WorksheetCreateScreenState();
}

class _WorksheetCreateScreenState extends State<WorksheetCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedMethod = 'pdf';
  String _selectedCategory = 'HTML/CSS';
  String? _selectedGroup;
  
  List<dynamic> _groups = [];
  List<String> _categories = ['HTML/CSS', 'JavaScript', 'Java', 'Spring', 'Database', '자료구조', '알고리즘', '기타'];
  
  List<Map<String, dynamic>> _extractedQuestions = [];
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploaded = false;

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

        setState(() {
          _extractedQuestions = List<Map<String, dynamic>>.from(response['questions'] ?? []);
          _isUploaded = true;
          
          if (_extractedQuestions.isNotEmpty && _titleController.text.isEmpty) {
            _titleController.text = fileName.replaceAll('.pdf', '');
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_extractedQuestions.length}개 문제 추출 완료!'),
            backgroundColor: Color(0xFF595048),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ OCR 실패: $e'),
            backgroundColor: Color(0xFF595048),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addBlankQuestion() {
    setState(() {
      _extractedQuestions.add({
        'questionNumber': _extractedQuestions.length + 1,
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

  Future<void> _saveWorksheet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_extractedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제를 추가해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.createWorksheet(
        _titleController.text,
        _descriptionController.text,
        _extractedQuestions,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ 문제지 저장 완료!')),
      );

      Navigator.pop(context, true);
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
        title: Text('문제지 생성', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: Color(0xFF595048),
        iconTheme: IconThemeData(color: Color(0xFFD9D4D2)),
        actions: [
          if (_extractedQuestions.isNotEmpty)
            TextButton.icon(
              onPressed: _saveWorksheet,
              icon: Icon(Icons.save, color: Color(0xFFD9D4D2)),
              label: Text(
                '저장 (${_extractedQuestions.length}문제)',
                style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
              ),
            ),
        ],
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
                    _buildBasicInfo(),
                    SizedBox(height: 20),
                    _buildMethodSelector(),
                    SizedBox(height: 20),
                    if (_selectedMethod == 'pdf' && !_isUploaded) _buildPdfUploadArea(),
                    if (_selectedMethod == 'manual' || _isUploaded) _buildQuestionsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfo() {
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
            '기본 정보',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'JoseonGulim',
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '문제지 제목',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            validator: (value) => value?.isEmpty ?? true ? '제목을 입력하세요' : null,
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: '설명 (선택사항)',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            maxLines: 2,
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: '카테고리',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                    filled: true,
                    fillColor: Color(0xFF0D0D0D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: Color(0xFF595048),
                  style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGroup,
                  decoration: InputDecoration(
                    labelText: '대상 그룹',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                    filled: true,
                    fillColor: Color(0xFF0D0D0D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: Color(0xFF595048),
                  style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                  hint: Text('전체', style: TextStyle(color: Color(0xFF736A63))),
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
              ),
            ],
          ),
        ],
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
            '문제 추가 방식',
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
                child: _buildMethodButton('📄 PDF 업로드', 'pdf', Icons.upload_file),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildMethodButton('✍️ 직접 작성', 'manual', Icons.edit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(String label, String method, IconData icon) {
    bool isSelected = _selectedMethod == method;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _selectedMethod = method;
          if (method == 'manual' && !_isUploaded) {
            _extractedQuestions.clear();
            _addBlankQuestion();
          }
        });
      },
      icon: Icon(icon, color: Color(0xFFD9D4D2)),
      label: Text(
        label,
        style: TextStyle(
          color: Color(0xFFD9D4D2),
          fontSize: 16,
          fontFamily: 'JoseonGulim',
        ),
      ),
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
    );
  }

  Widget _buildPdfUploadArea() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Color(0xFF595048),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF736A63), width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload, size: 80, color: Color(0xFFD9D4D2)),
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
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _uploadPdfAndExtract,
            icon: Icon(Icons.file_upload, size: 24),
            label: Text(
              'PDF 선택하기',
              style: TextStyle(fontSize: 20, fontFamily: 'JoseonGulim'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF736A63),
              foregroundColor: Color(0xFFD9D4D2),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF595048),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 목록 (${_extractedQuestions.length}개)',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JoseonGulim',
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addBlankQuestion,
                icon: Icon(Icons.add, size: 20),
                label: Text('문제 추가', style: TextStyle(fontFamily: 'JoseonGulim')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF736A63),
                  foregroundColor: Color(0xFFD9D4D2),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        ..._extractedQuestions.asMap().entries.map((entry) {
          return _buildQuestionCard(entry.key);
        }).toList(),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    var question = _extractedQuestions[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 15),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JoseonGulim',
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Color(0xFFD9D4D2)),
                onPressed: () {
                  setState(() {
                    _extractedQuestions.removeAt(index);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 15),
          TextFormField(
            initialValue: question['questionText'],
            decoration: InputDecoration(
              labelText: '문제',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
            maxLines: 3,
            onChanged: (value) => question['questionText'] = value,
          ),
          SizedBox(height: 15),
          _buildOptionField('보기 1', question, 'optionA'),
          _buildOptionField('보기 2', question, 'optionB'),
          _buildOptionField('보기 3', question, 'optionC'),
          _buildOptionField('보기 4', question, 'optionD'),
          SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: question['correctAnswer']?.toString() ?? '1',
            decoration: InputDecoration(
              labelText: '정답',
              labelStyle: TextStyle(color: Color(0xFF736A63)),
              filled: true,
              fillColor: Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Color(0xFF0D0D0D),
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
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

  Widget _buildOptionField(String label, Map<String, dynamic> question, String field) {
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
        onChanged: (value) => question[field] = value,
      ),
    );
  }
}
