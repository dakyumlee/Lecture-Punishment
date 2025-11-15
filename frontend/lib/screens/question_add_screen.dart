import '../services/api_service.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuestionAddScreen extends StatefulWidget {
  final String worksheetId;
  final String worksheetTitle;

  const QuestionAddScreen({super.key, required this.worksheetId, required this.worksheetTitle});

  @override
  State<QuestionAddScreen> createState() => _QuestionAddScreenState();
}

class _QuestionAddScreenState extends State<QuestionAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  
  String _questionType = 'subjective';
  int _questionNumber = 1;
  int _points = 10;
  bool _allowPartial = false;
  double _similarityThreshold = 0.85;
  bool _isLoading = false;

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final body = {
        'questionNumber': _questionNumber,
        'questionType': _questionType,
        'questionText': _questionTextController.text,
        'correctAnswer': _correctAnswerController.text,
        'points': _points,
        'allowPartial': _allowPartial,
        'similarityThreshold': _similarityThreshold.toString(),
      };

      if (_questionType == 'multiple_choice') {
        body['optionA'] = _optionAController.text;
        body['optionB'] = _optionBController.text;
        body['optionC'] = _optionCController.text;
        body['optionD'] = _optionDController.text;
      }

      await ApiService.addQuestion(widget.worksheetId, body);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문제가 추가되었습니다!')),
        );
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
        title: Text('문제 추가 - ${widget.worksheetTitle}', 
          style: const TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _questionNumber.toString(),
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '문제 번호',
                        labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                      ),
                      onChanged: (v) => _questionNumber = int.tryParse(v) ?? 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _questionType,
                      dropdownColor: const Color(0xFF595048),
                      style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                      decoration: const InputDecoration(
                        labelText: '문제 유형',
                        labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'subjective', child: Text('주관식')),
                        DropdownMenuItem(value: 'multiple_choice', child: Text('객관식')),
                      ],
                      onChanged: (val) => setState(() => _questionType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionTextController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '문제 내용',
                  labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                ),
                validator: (v) => v?.isEmpty ?? true ? '문제를 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              if (_questionType == 'multiple_choice') ...[
                TextFormField(
                  controller: _optionAController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '① 선택지 A',
                    labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '선택지를 입력하세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _optionBController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '② 선택지 B',
                    labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '선택지를 입력하세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _optionCController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '③ 선택지 C',
                    labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '선택지를 입력하세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _optionDController,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '④ 선택지 D',
                    labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '선택지를 입력하세요' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _correctAnswerController,
                style: const TextStyle(color: Color(0xFFD9D4D2)),
                decoration: InputDecoration(
                  labelText: _questionType == 'multiple_choice' ? '정답 (A, B, C, D 중 하나)' : '정답',
                  labelStyle: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                ),
                validator: (v) => v?.isEmpty ?? true ? '정답을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _points.toString(),
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '배점',
                        labelStyle: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF595048))),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD9D4D2))),
                      ),
                      onChanged: (v) => _points = int.tryParse(v) ?? 10,
                    ),
                  ),
                ],
              ),
              if (_questionType == 'subjective') ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('부분 점수 허용', style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
                  value: _allowPartial,
                  activeColor: const Color(0xFFD9D4D2),
                  onChanged: (val) => setState(() => _allowPartial = val),
                ),
                const SizedBox(height: 8),
                Text('유사도 임계값: ${(_similarityThreshold * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim')),
                Slider(
                  value: _similarityThreshold,
                  min: 0.5, max: 1.0,
                  activeColor: const Color(0xFFD9D4D2),
                  inactiveColor: const Color(0xFF595048),
                  onChanged: (val) => setState(() => _similarityThreshold = val),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _addQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595048),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFD9D4D2))
                    : const Text('문제 추가', style: TextStyle(fontFamily: 'JoseonGulim', fontSize: 18, color: Color(0xFFD9D4D2))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _correctAnswerController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }
}
