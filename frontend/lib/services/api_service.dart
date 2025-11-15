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
    final response = await http.get(Uri.parse('$baseUrl/quizzes/$bossId'));
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

  static Future<void> createLesson({required String title, required String description}) async {
    await http.post(
      Uri.parse('$baseUrl/admin/lessons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );
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

  static Future<bool> deleteStudent(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/students/$id'));
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getWorksheetWithQuestions(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/worksheets/$id/questions'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitWorksheet({
    required String worksheetId,
    required String studentId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'answers': answers}),
    );
    return jsonDecode(response.body);
  }

  static Future<void> createWorksheet({required String title, String? description}) async {
    await http.post(
      Uri.parse('$baseUrl/worksheets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );
  }

  static Future<Map<String, dynamic>> uploadPdfWorksheet({
    required String title,
    required String description,
    required String category,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/worksheets'),
    );
    
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('업로드 실패: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getAllWorksheets() async {
    final response = await http.get(Uri.parse('$baseUrl/worksheets/all'));
    return jsonDecode(response.body) as List;
  }

  static Future<bool> deleteWorksheet(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/worksheets/$id'));
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllGroups() async {
    final response = await http.get(Uri.parse('$baseUrl/groups'));
    return jsonDecode(response.body) as List;
  }

  static Future<void> createGroup({
    required String name, 
    String? description,
    int? year,
    String? course,
    String? period,
  }) async {
    final Map<String, dynamic> body = {
      'groupName': name,
    };
    if (description != null) body['description'] = description;
    if (year != null) body['year'] = year;
    if (course != null) body['course'] = course;
    if (period != null) body['period'] = period;

    await http.post(
      Uri.parse('$baseUrl/groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<bool> deleteGroup(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/groups/$id'));
    return response.statusCode == 200;
  }

  static Future<void> downloadGroupExcel(String groupId, String groupName) async {
    final response = await http.get(Uri.parse('$baseUrl/excel/groups/$groupId'));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = '${groupName}_성적표.xlsx'
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  static Future<void> downloadAllStudentsExcel() async {
    final response = await http.get(Uri.parse('$baseUrl/excel/students/all'));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = '전체학생_성적표.xlsx'
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  static Future<List<dynamic>> getGroupStudents(String groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/groups/$groupId/students'));
    return jsonDecode(response.body) as List;
  }

  static Future<bool> removeStudentFromGroup({required String groupId, required String studentId}) async {
    final response = await http.delete(Uri.parse('$baseUrl/groups/$groupId/students/$studentId'));
    return response.statusCode == 200;
  }

  static Future<bool> assignStudentToGroup({required String groupId, required String studentId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/$groupId/students'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId}),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAllSubmissions() async {
    final response = await http.get(Uri.parse('$baseUrl/submissions'));
    return jsonDecode(response.body) as List;
  }

  static Future<Map<String, dynamic>> getSubmissionDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/submissions/$id'));
    return jsonDecode(response.body);
  }

  static Future<bool> gradeAnswer({
    required String submissionId,
    required String answerId,
    required bool isCorrect,
    required int score,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submissions/$submissionId/grade'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'answerId': answerId, 'isCorrect': isCorrect, 'score': score}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> addQuestionToWorksheet(String worksheetId, Map<String, dynamic> question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(question),
    );
    return response.statusCode == 200;
  }

  static Future<void> addQuestion(String worksheetId, Map<String, dynamic> question) async {
    await addQuestionToWorksheet(worksheetId, question);
  }

  static Future<Map<String, dynamic>> changeExpression({
    required String studentId,
    required String expression,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/expression'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'expression': expression}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> completeProfile({
    required String studentId,
    String? birthDate,
    String? phoneNumber,
  }) async {
    final Map<String, String> body = {'studentId': studentId};
    if (birthDate != null && birthDate.isNotEmpty) {
      body['birthDate'] = birthDate;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/profile/complete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyPageData(String studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId/mypage'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String studentId,
    String? displayName,
    String? birthDate,
    String? phoneNumber,
    String? studentIdNumber,
  }) async {
    final Map<String, String> body = {};
    if (displayName != null) body['displayName'] = displayName;
    if (birthDate != null) body['birthDate'] = birthDate;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (studentIdNumber != null) body['studentIdNumber'] = studentIdNumber;

    final response = await http.put(
      Uri.parse('$baseUrl/students/$studentId/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }
}
