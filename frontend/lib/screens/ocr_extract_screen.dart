import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env.dart';

class OcrExtractScreen extends StatefulWidget {
  const OcrExtractScreen({super.key});
  @override
  State<OcrExtractScreen> createState() => _OcrExtractScreenState();
}
class _OcrExtractScreenState extends State<OcrExtractScreen> {
  bool _isProcessing = false;
  List<dynamic> _extractedQuestions = [];
  String? _fileName;
  List<bool> _selectedQuestions = [];
  Future<void> _pickAndExtract() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isProcessing = true;
        _fileName = result.files.single.name;
      });
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Env.apiUrl}/ocr/extract'),
        );
        
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          result.files.single.bytes!,
          filename: result.files.single.name,
        ));
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _extractedQuestions = data['questions'] ?? [];
            _selectedQuestions = List.filled(_extractedQuestions.length, true);
            _isProcessing = false;
          });
          if (_extractedQuestions.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('문제를 찾을 수 없습니다')),
              );
            }
          }
        } else {
          throw Exception('OCR 실패: ${response.statusCode}');
        }
      } catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OCR 실패: $e')),
          );
      }
    }
  }
  Future<void> _addToWorksheet() async {
    try {
      final worksheets = await ApiService.getWorksheets();
      
      if (worksheets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문제지가 없습니다. 먼저 문제지를 생성하세요.')),
        return;
      if (!mounted) return;
      final selectedWorksheet = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF595048),
          title: const Text(
            '문제지 선택',
            style: TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: worksheets.length,
              itemBuilder: (context, index) {
                final worksheet = worksheets[index];
                return ListTile(
                  title: Text(
                    worksheet.title,
                    style: const TextStyle(color: Color(0xFFD9D4D2)),
                  ),
                  subtitle: Text(
                    worksheet.description ?? '',
                    style: const TextStyle(color: Color(0xFF736A63)),
                  onTap: () => Navigator.pop(context, worksheet.id),
                );
              },
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Color(0xFF736A63))),
          ],
        ),
      );
      if (selectedWorksheet != null && mounted) {
        setState(() => _isProcessing = true);
        int addedCount = 0;
        for (int i = 0; i < _extractedQuestions.length; i++) {
          if (_selectedQuestions[i]) {
            final question = _extractedQuestions[i];
            
            final questionData = {
              'questionNumber': question['questionNumber'],
              'questionType': question['questionType'],
              'questionText': question['questionText'],
              'optionA': question['optionA'],
              'optionB': question['optionB'],
              'optionC': question['optionC'],
              'optionD': question['optionD'],
              'correctAnswer': '',
              'points': 10,
            };
            final success = await ApiService.addQuestionToWorksheet(
              selectedWorksheet,
              questionData,
            );
            if (success) addedCount++;
            SnackBar(content: Text('$addedCount개 문제를 추가했습니다!')),
          Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
          SnackBar(content: Text('추가 실패: $e')),
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          'OCR 문제 추출',
          style: TextStyle(
            fontFamily: 'JoseonGulim',
            color: Color(0xFFD9D4D2),
        backgroundColor: const Color(0xFF00010D),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: _extractedQuestions.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addToWorksheet,
                  tooltip: '문제지에 추가',
                ),
              ]
            : null,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFD9D4D2)),
                  const SizedBox(height: 16),
                  Text(
                    _extractedQuestions.isEmpty ? 'PDF에서 문제 추출 중...' : '문제 추가 중...',
                    style: const TextStyle(
                      color: Color(0xFF736A63),
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                    ),
                  if (_fileName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _fileName!,
                      style: const TextStyle(
                        color: Color(0xFF595048),
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                      ),
                  ],
                ],
              ),
            )
          : _extractedQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.document_scanner,
                        size: 80,
                      const SizedBox(height: 24),
                      const Text(
                        'PDF 파일을 업로드하여\n문제를 자동으로 추출하세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                          fontSize: 18,
                        ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _pickAndExtract,
                        icon: const Icon(Icons.upload_file),
                        label: const Text(
                          'PDF 업로드',
                          style: TextStyle(
                            fontFamily: 'JoseonGulim',
                            fontSize: 16,
                          ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D4D2),
                          foregroundColor: const Color(0xFF00010D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                    ],
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFF595048),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '추출된 문제: ${_extractedQuestions.length}개',
                            style: const TextStyle(
                              color: Color(0xFFD9D4D2),
                              fontFamily: 'JoseonGulim',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _addToWorksheet,
                                icon: const Icon(Icons.add_circle, size: 18),
                                label: const Text('문제지에 추가'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD9D4D2),
                                  foregroundColor: const Color(0xFF00010D),
                                ),
                              ),
                              const SizedBox(width: 8),
                                onPressed: _pickAndExtract,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('다시 추출'),
                                  backgroundColor: const Color(0xFF736A63),
                                  foregroundColor: const Color(0xFFD9D4D2),
                            ],
                        ],
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _extractedQuestions.length,
                        itemBuilder: (context, index) {
                          final question = _extractedQuestions[index];
                          return _buildQuestionCard(question, index);
                        },
  Future<void> _editQuestion(int index) async {
    final question = _extractedQuestions[index];
    final isMultipleChoice = question['questionType'] == 'multiple_choice';
    
    final questionTextController = TextEditingController(text: question['questionText']);
    final optionAController = TextEditingController(text: question['optionA'] ?? '');
    final optionBController = TextEditingController(text: question['optionB'] ?? '');
    final optionCController = TextEditingController(text: question['optionC'] ?? '');
    final optionDController = TextEditingController(text: question['optionD'] ?? '');
    String correctAnswer = question['correctAnswer'] ?? '';
    bool isObjective = isMultipleChoice;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            '${question['questionNumber']}번 문제 수정',
            style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    const Text('문제 유형:', style: TextStyle(color: Color(0xFFD9D4D2))),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('주관식'),
                      selected: !isObjective,
                      onSelected: (selected) {
                        setDialogState(() {
                          isObjective = false;
                        });
                      },
                    const SizedBox(width: 8),
                      label: const Text('객관식'),
                      selected: isObjective,
                          isObjective = true;
                const SizedBox(height: 16),
                TextField(
                  controller: questionTextController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFFD9D4D2)),
                  decoration: const InputDecoration(
                    labelText: '문제',
                    labelStyle: TextStyle(color: Color(0xFF736A63)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF736A63)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                if (isObjective) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: optionAController,
                    decoration: const InputDecoration(
                      labelText: '① 보기',
                      labelStyle: TextStyle(color: Color(0xFF736A63)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF736A63)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD9D4D2)),
                  const SizedBox(height: 8),
                    controller: optionBController,
                      labelText: '② 보기',
                    controller: optionCController,
                      labelText: '③ 보기',
                    controller: optionDController,
                      labelText: '④ 보기',
                  const Divider(color: Color(0xFF736A63)),
                  const Text(
                    '정답 선택',
                    style: TextStyle(color: Color(0xFFD9D4D2), fontWeight: FontWeight.bold),
                  if (isObjective) ...[
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('①'),
                          selected: correctAnswer == 'A',
                          onSelected: (selected) {
                            setDialogState(() {
                              correctAnswer = 'A';
                            });
                          },
                          label: const Text('②'),
                          selected: correctAnswer == 'B',
                              correctAnswer = 'B';
                          label: const Text('③'),
                          selected: correctAnswer == 'C',
                              correctAnswer = 'C';
                          label: const Text('④'),
                          selected: correctAnswer == 'D',
                              correctAnswer = 'D';
                      ],
                  ] else ...[
                    TextField(
                      controller: TextEditingController(text: correctAnswer),
                      onChanged: (value) {
                        correctAnswer = value;
                      style: const TextStyle(color: Color(0xFFD9D4D2)),
                      decoration: const InputDecoration(
                        labelText: '정답 입력',
                        labelStyle: TextStyle(color: Color(0xFF736A63)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF736A63)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD9D4D2)),
              ],
              onPressed: () {
                setState(() {
                  _extractedQuestions[index] = {
                    'questionNumber': question['questionNumber'],
                    'questionType': isObjective ? 'multiple_choice' : 'subjective',
                    'questionText': questionTextController.text,
                    'optionA': isObjective ? optionAController.text : null,
                    'optionB': isObjective ? optionBController.text : null,
                    'optionC': isObjective ? optionCController.text : null,
                    'optionD': isObjective ? optionDController.text : null,
                    'correctAnswer': correctAnswer,
                  };
                });
                Navigator.pop(context);
              child: const Text('저장', style: TextStyle(color: Color(0xFFD9D4D2))),
  Widget _buildQuestionCard(dynamic question, int index) {
    final questionNumber = question['questionNumber'] ?? (index + 1);
    final questionType = question['questionType'] ?? 'subjective';
    final questionText = question['questionText'] ?? '';
    final isMultipleChoice = questionType == 'multiple_choice';
    return Card(
      color: const Color(0xFF595048),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                Checkbox(
                  value: _selectedQuestions[index],
                  onChanged: (value) {
                    setState(() {
                      _selectedQuestions[index] = value ?? false;
                    });
                  },
                  fillColor: WidgetStateProperty.all(const Color(0xFFD9D4D2)),
                  checkColor: const Color(0xFF00010D),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00010D),
                    borderRadius: BorderRadius.circular(4),
                  child: Text(
                    '$questionNumber번',
                      color: Color(0xFFD9D4D2),
                      fontWeight: FontWeight.bold,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: isMultipleChoice ? const Color(0xFF736A63) : const Color(0xFFD9D4D2),
                    isMultipleChoice ? '객관식' : '주관식',
                    style: TextStyle(
                      color: isMultipleChoice ? const Color(0xFFD9D4D2) : const Color(0xFF00010D),
                      fontSize: 12,
                const Spacer(),
                  icon: const Icon(Icons.edit, color: Color(0xFFD9D4D2), size: 20),
                  onPressed: () => _editQuestion(index),
                  tooltip: '문제 수정',
            const SizedBox(height: 12),
            Text(
              questionText,
              style: const TextStyle(
                color: Color(0xFFD9D4D2),
                fontFamily: 'JoseonGulim',
                fontSize: 14,
            if (isMultipleChoice) ...[
              const SizedBox(height: 12),
              if (question['optionA'] != null)
                _buildOption('①', question['optionA']),
              if (question['optionB'] != null)
                _buildOption('②', question['optionB']),
              if (question['optionC'] != null)
                _buildOption('③', question['optionC']),
              if (question['optionD'] != null)
                _buildOption('④', question['optionD']),
            ],
  Widget _buildOption(String marker, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$marker $text',
        style: const TextStyle(
          color: Color(0xFF736A63),
          fontFamily: 'JoseonGulim',
          fontSize: 13,
