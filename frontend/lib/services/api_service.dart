import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../models/instructor.dart';
import '../models/quiz.dart';
import '../models/boss.dart';
import '../models/worksheet.dart';
import '../models/shop_item.dart';
import '../models/student.dart';
import '../config/env.dart';

class ApiService {
  static String get baseUrl => Env.apiUrl;

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> loginWithAuth(Map<String, dynamic> credentials) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials),
    );
    
    if (response.statusCode == 400) {
      return jsonDecode(response.body);
    }
    
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> setPassword(String studentId, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/set-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Student> getStudent(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/students/$id'));
    return Student.fromJson(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<Quiz>> getQuizzes(String bossId) async {
    final response = await http.get(Uri.parse('$baseUrl/quizzes/boss/$bossId'));
    final data = jsonDecode(response.body) as List;
    return data.map((json) => Quiz.fromJson(json)).toList();
  }

  static Future<List<Boss>> getBosses() async {
    final response = await http.get(Uri.parse('$baseUrl/bosses'));
    final data = jsonDecode(response.body) as List;
    return data.map((json) => Boss.fromJson(json)).toList();
  }

  static Future<List<Worksheet>> getWorksheets() async {
    final response = await http.get(Uri.parse('$baseUrl/worksheets'));
    final data = jsonDecode(response.body) as List;
    return data.map((json) => Worksheet.fromJson(json)).toList();
  }

  static Future<Map<String, dynamic>> getWorksheetsGrouped() async {
    final response = await http.get(Uri.parse('$baseUrl/worksheets/grouped'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getShopItems() async {
    final response = await http.get(Uri.parse('$baseUrl/shop/items'));
    final data = jsonDecode(response.body) as List;
    return {
      'items': data,
      'groupedItems': {'outfit': data, 'face': [], 'accessory': []},
    };
  }

  Future<List<Student>> getTopStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students/top'));
    final data = jsonDecode(response.body) as List;
    return data.map((json) => Student.fromJson(json)).toList();
  }

  static Future<Map<String, dynamic>> getStudentInventory(String studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/shop/inventory/$studentId'));
    return {'points': 100, 'items': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> buyItem({required String studentId, required String itemId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shop/buy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'itemId': itemId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/stats'));
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getActiveGroups() async {
    final response = await http.get(Uri.parse('$baseUrl/groups/active'));
    return jsonDecode(response.body) as List;
  }

  static Future<void> createLesson({
    required String title, 
    required String description,
    String? groupId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/lessons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title, 
        'description': description,
        'subject': description,
        'groupId': groupId,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('수업 생성 실패: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAdminLessons() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/lessons'));
    return jsonDecode(response.body) as List;
  }

  static Future<bool> deleteLesson(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/lessons/$id'));
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAdminStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/students'));
    return jsonDecode(response.body) as List;
  }

  static Future<List<dynamic>> getAllStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/students'));
    return jsonDecode(response.body) as List;
  }

  static Future<bool> deleteStudent(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/students/$id'));
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> createStudent({
    required String username,
    required String displayName,
    String? groupId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/students'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'displayName': displayName,
        'groupId': groupId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('학생 생성 실패: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> assignStudentToGroup({
    required String groupId,
    required String studentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/$groupId/students/$studentId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('학생 배정 실패: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWorksheetWithQuestions(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/worksheets/$id'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitWorksheet({
    required String worksheetId,
    required String studentId,
    required List<Map<String, String>> answers,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/worksheet-submissions"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "worksheetId": worksheetId,
        "studentId": studentId,
        "answers": answers,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadPdfWorksheet({
    required String title,
    required String description,
    required String category,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/worksheets/pdf'));
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('업로드 실패: ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<bool> addQuestionToWorksheet(String worksheetId, Map<String, dynamic> questionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(questionData),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllGroups() async {
    final response = await http.get(Uri.parse('$baseUrl/groups'));
    return jsonDecode(response.body) as List;
  }

  static Future<Map<String, dynamic>> createGroup({
    required String name,
    int? year,
    required String course,
    required String period,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupName': name,
        'year': year,
        'course': course,
        'period': period,
        'description': description,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<void> deleteGroup(String groupId) async {
    await http.delete(Uri.parse('$baseUrl/groups/$groupId'));
  }

  static Future<List<dynamic>> getGroupStudents(String groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/groups/$groupId/students'));
    return jsonDecode(response.body) as List;
  }

  static Future<void> removeStudentFromGroup({required String groupId, required String studentId}) async {
    await http.delete(Uri.parse('$baseUrl/groups/$groupId/students/$studentId'));
  }

  static Future<void> downloadGroupExcel(String groupId, String groupName) async {
    final response = await http.get(Uri.parse('$baseUrl/excel/groups/$groupId'));
    final bytes = response.bodyBytes;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$groupName.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<void> downloadAllStudentsExcel() async {
    final response = await http.get(Uri.parse('$baseUrl/excel/students/all'));
    final bytes = response.bodyBytes;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '전체학생_성적표.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<Map<String, dynamic>> completeProfile(String studentId, Map<String, String> profileData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profileData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyPageData(String studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/students/$studentId/mypage'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile(String studentId, Map<String, String> profileData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/$studentId/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profileData),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAllWorksheets() async {
    final response = await http.get(Uri.parse('$baseUrl/worksheets'));
    return jsonDecode(response.body) as List;
  }

  static Future<bool> deleteWorksheet(String worksheetId) async {
    final response = await http.delete(Uri.parse('$baseUrl/worksheets/$worksheetId'));
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllSubmissions() async {
    final response = await http.get(Uri.parse('$baseUrl/grading/submissions'));
    return jsonDecode(response.body) as List;
  }

  static Future<Map<String, dynamic>> getSubmissionDetail(String submissionId) async {
    final response = await http.get(Uri.parse('$baseUrl/grading/submissions/$submissionId'));
    return jsonDecode(response.body);
  }

  static Future<bool> gradeAnswer(String answerId, bool isCorrect, int score) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grading/answers/$answerId/grade'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isCorrect': isCorrect, 'score': score}),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> changeExpression(String studentId, String expression) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/expression'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'expression': expression}),
    );
    return jsonDecode(response.body);
  }

  static Future<bool> addQuestion(String worksheetId, Map<String, dynamic> questionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(questionData),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> submitQuizAnswer({
    required String quizId,
    required String studentId,
    required String selectedAnswer,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quizzes/$quizId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'selectedAnswer': selectedAnswer,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRandomRage() async {
    final response = await http.get(Uri.parse('$baseUrl/game/rage/random'));
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  static Future<Student> getStudentByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/game/student/$username'));
    return Student.fromJson(jsonDecode(response.body));
  }

  static Future<List<dynamic>> getRanking() async {
    final response = await http.get(Uri.parse('$baseUrl/ranking'));
    return jsonDecode(response.body) as List;
  }

  static Future<Map<String, dynamic>> createWorksheet(
    String title, 
    String description, 
    String category, 
    List<Map<String, dynamic>> questions,
    {List<int>? fileBytes, String? fileName}
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/worksheets'));
    
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['questions'] = jsonEncode(questions);
    
    if (fileBytes != null && fileName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'originalFile',
        fileBytes,
        filename: fileName,
      ));
    }
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode != 200) {
      throw Exception('문제지 생성 실패: ${response.statusCode}');
    }
    
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> extractQuestionsFromPdf({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ocr/extract'));
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('OCR 실패: ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<Map<String, dynamic>> createQuiz({
    required String category,
    String? groupId,
    required Map<String, dynamic> questionData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quizzes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'groupId': groupId,
        ...questionData,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('퀴즈 생성 실패: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAvailableDungeons(String studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/dungeons/student/$studentId'));
    return jsonDecode(response.body) as List;
  }

  static Future<Map<String, dynamic>> getDungeonEntrance(String lessonId) async {
    final response = await http.get(Uri.parse('$baseUrl/dungeons/lesson/$lessonId/entrance'));
    return jsonDecode(response.body);
  }
}
