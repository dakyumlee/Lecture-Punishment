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
  String? _selectedGroup;
  
  List<dynamic> _groups = [];
  
  List<Map<String, dynamic>> _ocrExtractedQuestions = [];
  List<Map<String, dynamic>> _confirmedQuestions = [];
  int _currentQuestionIndex = 0;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  
  Map<String, TextEditingController> _questionControllers = {};
  
  bool _isLoading = false;
  bool _isOcrDone = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _questionControllers.values.forEach((controller) => controller.dispose());
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
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

  void _initControllers(Map<String, dynamic> question) {
    _questionControllers = {
      'questionText': TextEditingController(text: question['questionText'] ?? ''),
      'optionA': TextEditingController(text: question['optionA'] ?? ''),
      'optionB': TextEditingController(text: question['optionB'] ?? ''),
      'optionC': TextEditingController(text: question['optionC'] ?? ''),
      'optionD': TextEditingController(text: question['optionD'] ?? ''),
    };
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
          _ocrExtractedQuestions = List<Map<String, dynamic>>.from(response['questions'] ?? []);
          _isOcrDone = true;
          _currentQuestionIndex = 0;
          
          if (_ocrExtractedQuestions.isNotEmpty) {
            _initControllers(_ocrExtractedQuestions[0]);
            if (_titleController.text.isEmpty) {
              _titleController.text = fileName.replaceAll('.pdf', '');
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_ocrExtractedQuestions.length}개 문제 추출 완료! 하나씩 확인하세요'),
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

  void _addCurrentQuestion() {
    final currentQuestion = _ocrExtractedQuestions[_currentQuestionIndex];
    
    final confirmedQuestion = {
      'questionNumber': _confirmedQuestions.length + 1,
      'questionType': 'multiple_choice',
      'questionText': _questionControllers['questionText']!.text,
      'optionA': _questionControllers['optionA']!.text,
      'optionB': _questionControllers['optionB']!.text,
      'optionC': _questionControllers['optionC']!.text,
      'optionD': _questionControllers['optionD']!.text,
      'correctAnswer': currentQuestion['correctAnswer'] ?? '1',
      'points': 10,
    };

    setState(() {
      _confirmedQuestions.add(confirmedQuestion);
      
      if (_currentQuestionIndex < _ocrExtractedQuestions.length - 1) {
        _currentQuestionIndex++;
        _questionControllers.values.forEach((c) => c.dispose());
        _initControllers(_ocrExtractedQuestions[_currentQuestionIndex]);
      } else {
        _isOcrDone = false;
        _ocrExtractedQuestions.clear();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ 문제 추가됨 (${_confirmedQuestions.length}개)')),
    );
  }

  void _skipCurrentQuestion() {
    if (_currentQuestionIndex < _ocrExtractedQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _questionControllers.values.forEach((c) => c.dispose());
        _initControllers(_ocrExtractedQuestions[_currentQuestionIndex]);
      });
    } else {
      setState(() {
        _isOcrDone = false;
        _ocrExtractedQuestions.clear();
      });
    }
  }

  void _addBlankQuestion() {
    final newQuestion = {
      'questionNumber': _confirmedQuestions.length + 1,
      'questionType': 'multiple_choice',
      'questionText': '',
      'optionA': '',
      'optionB': '',
      'optionC': '',
      'optionD': '',
      'correctAnswer': '1',
      'points': 10,
    };
    
    setState(() {
      _confirmedQuestions.add(newQuestion);
    });
  }

  Future<void> _saveWorksheet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_confirmedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최소 1개 이상의 문제를 추가해주세요')),
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
        _confirmedQuestions,
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
          if (_confirmedQuestions.isNotEmpty)
            TextButton.icon(
              onPressed: _saveWorksheet,
              icon: Icon(Icons.save, color: Color(0xFFD9D4D2)),
              label: Text(
                '저장 (${_confirmedQuestions.length})',
                style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim', fontWeight: FontWeight.bold),
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
                    if (_selectedMethod == 'pdf' && !_isOcrDone) _buildPdfUploadArea(),
                    if (_isOcrDone) _buildCurrentQuestionEditor(),
                    if (_confirmedQuestions.isNotEmpty) _buildConfirmedQuestionsList(),
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
                child: TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: '카테고리 (예: HTML, JavaScript, Java)',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                    filled: true,
                    fillColor: Color(0xFF0D0D0D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
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
          if (method == 'manual') {
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
        border: Border.all(color: Color(0xFF736A63), width: 2),
      ),
      child: Column(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestionEditor() {
    if (_ocrExtractedQuestions.isEmpty) return SizedBox();
    
    final currentQuestion = _ocrExtractedQuestions[_currentQuestionIndex];
    
    return Container(
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
                '문제 ${_currentQuestionIndex + 1} / ${_ocrExtractedQuestions.length}',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JoseonGulim',
                ),
              ),
              Text(
                '확정: ${_confirmedQuestions.length}개',
                style: TextStyle(
                  color: Color(0xFF736A63),
                  fontSize: 16,
                  fontFamily: 'JoseonGulim',
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildTextField('문제', 'questionText', maxLines: 3),
          SizedBox(height: 15),
          _buildTextField('보기 1', 'optionA'),
          _buildTextField('보기 2', 'optionB'),
          _buildTextField('보기 3', 'optionC'),
          _buildTextField('보기 4', 'optionD'),
          SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: currentQuestion['correctAnswer']?.toString() ?? '1',
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
                currentQuestion['correctAnswer'] = value;
              });
            },
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _skipCurrentQuestion,
                  icon: Icon(Icons.skip_next),
                  label: Text('건너뛰기', style: TextStyle(fontFamily: 'JoseonGulim')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D0D0D),
                    foregroundColor: Color(0xFFD9D4D2),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _addCurrentQuestion,
                  icon: Icon(Icons.add_circle),
                  label: Text('이 문제 추가', style: TextStyle(fontFamily: 'JoseonGulim', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF736A63),
                    foregroundColor: Color(0xFFD9D4D2),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String field, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _questionControllers[field],
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
      ),
    );
  }

  Widget _buildConfirmedQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
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
                '추가된 문제 (${_confirmedQuestions.length}개)',
                style: TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JoseonGulim',
                ),
              ),
              if (_selectedMethod == 'manual')
                ElevatedButton.icon(
                  onPressed: _addBlankQuestion,
                  icon: Icon(Icons.add, size: 18),
                  label: Text('빈 문제 추가', style: TextStyle(fontFamily: 'JoseonGulim')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF736A63),
                    foregroundColor: Color(0xFFD9D4D2),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10),
        ..._confirmedQuestions.asMap().entries.map((entry) {
          int index = entry.key;
          var q = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFF595048)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${q['questionText']}',
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '정답: ${q['correctAnswer']}번',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _confirmedQuestions.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
