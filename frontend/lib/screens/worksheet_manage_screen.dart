import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'question_add_screen.dart';

class WorksheetManageScreen extends StatefulWidget {
  const WorksheetManageScreen({super.key});

  @override
  State<WorksheetManageScreen> createState() => _WorksheetManageScreenState();
}

class _WorksheetManageScreenState extends State<WorksheetManageScreen> {
  List<dynamic> _worksheets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/worksheets'));
      if (response.statusCode == 200) {
        setState(() {
          _worksheets = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('문제지 관리', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
          : _worksheets.isEmpty
              ? const Center(child: Text('문제지가 없습니다', 
                  style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _worksheets.length,
                  itemBuilder: (context, index) {
                    final worksheet = _worksheets[index];
                    return Card(
                      color: const Color(0xFF595048),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(
                          worksheet['title'],
                          style: const TextStyle(
                            color: Color(0xFFD9D4D2),
                            fontFamily: 'JoseonGulim',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${worksheet['category']} | 문제 ${worksheet['totalQuestions']}개',
                          style: const TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim'),
                        ),
                        iconColor: const Color(0xFFD9D4D2),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  worksheet['description'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFFD9D4D2),
                                    fontFamily: 'JoseonGulim',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuestionAddScreen(
                                          worksheetId: worksheet['id'],
                                          worksheetTitle: worksheet['title'],
                                        ),
                                      ),
                                    );
                                    if (result == true) _loadWorksheets();
                                  },
                                  icon: const Icon(Icons.add, color: Color(0xFF00010D)),
                                  label: const Text(
                                    '문제 추가',
                                    style: TextStyle(
                                      fontFamily: 'JoseonGulim',
                                      color: Color(0xFF00010D),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD9D4D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
