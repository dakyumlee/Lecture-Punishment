import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/game_models.dart';
import '../config/env.dart';

class ApiService {
  static String get baseUrl => Env.apiUrl;

  Future<Student?> getStudentByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/username/$username'),
      );
      if (response.statusCode == 200) {
        return Student.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  Future<Student> createStudent(String username, String displayName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'displayName': displayName,
      }),
    );
    return Student.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<Student> getStudent(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/students/$id'));
    return Student.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<Instructor> getInstructorByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/instructors/name/$name'));
    return Instructor.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<Lesson> getTodayLesson() async {
    final response = await http.get(Uri.parse('$baseUrl/lessons/today'));
    return Lesson.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<Boss> getBossByLesson(String lessonId) async {
    final response = await http.get(Uri.parse('$baseUrl/bosses/lesson/$lessonId'));
    return Boss.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<List<Quiz>> getQuizzesByBoss(String bossId) async {
    final response = await http.get(Uri.parse('$baseUrl/quizzes/boss/$bossId'));
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Quiz.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> submitAnswer(String studentId, String quizId, String answer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'quizId': quizId,
        'answer': answer,
      }),
    );
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<Student>> getTopStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/ranking/top'));
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Student.fromJson(json)).toList();
  }

  static Future<bool> adminLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> createWorksheet({
    required String title,
    required String description,
    required String category,
    required dynamic file,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/worksheets'),
    );
    
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    
    if (file != null && file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
        contentType: http.MediaType('application', 'pdf'),
      ));
    }
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to create worksheet: $responseBody');
    }
  }

  static Future<Map<String, dynamic>> addQuestion(
    String worksheetId,
    Map<String, dynamic> question,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(question),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to add question');
    }
  }

  static Future<List<dynamic>> getAllWorksheets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/worksheets'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getWorksheetsGrouped() async {
    final response = await http.get(
      Uri.parse('$baseUrl/worksheets/grouped'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getWorksheetWithQuestions(
    String worksheetId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/worksheets/$worksheetId'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load worksheet');
    }
  }

  static Future<Map<String, dynamic>> submitWorksheet({
    required String worksheetId,
    required String studentId,
    required List<Map<String, String>> answers,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'answers': answers,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to submit worksheet');
    }
  }

  static Future<Map<String, dynamic>> getStudentSubmissions(
    String studentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/worksheets/student/$studentId/submissions'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return {'submissions': []};
    }
  }

  static Future<Map<String, dynamic>> getShopItems({String? type}) async {
    String url = '$baseUrl/shop/items';
    if (type != null && type.isNotEmpty) {
      url += '?type=$type';
    }
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return {'items': [], 'groupedItems': {}};
    }
  }

  static Future<Map<String, dynamic>> buyItem({
    required String studentId,
    required String itemId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shop/buy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'itemId': itemId,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['message'] ?? '구매 실패');
    }
  }

  static Future<Map<String, dynamic>> getStudentInventory(String studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/shop/student/$studentId'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return {'points': 0, 'currentOutfit': null, 'currentExpression': null};
    }
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/stats'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return {};
    }
  }

  static Future<List<dynamic>> getAdminStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/students'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }

  static Future<bool> deleteStudent(String studentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/students/$studentId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getAdminLessons() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/lessons'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createLesson({
    required String title,
    required String subject,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/lessons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'subject': subject,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to create lesson');
    }
  }

  static Future<bool> deleteLesson(String lessonId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/lessons/$lessonId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteWorksheet(String worksheetId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/worksheets/$worksheetId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getAllGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createGroup({
    required String groupName,
    required int year,
    required String course,
    required String period,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupName': groupName,
        'year': year,
        'course': course,
        'period': period,
        'description': description ?? '',
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to create group');
    }
  }

  static Future<bool> deleteGroup(String groupId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/groups/$groupId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> updateGroup({
    required String groupId,
    required String groupName,
    required int year,
    required String course,
    required String period,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/groups/$groupId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupName': groupName,
        'year': year,
        'course': course,
        'period': period,
        'description': description ?? '',
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to update group');
    }
  }

  static Future<bool> assignStudentToGroup({
    required String studentId,
    required String groupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups/$groupId/students/$studentId'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getGroupStudents(String groupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/students'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }

  static Future<void> downloadGroupExcel(String groupId, String groupName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/export/group/$groupId/excel'),
      );
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '${groupName}_성적표.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      throw Exception('Excel 다운로드 실패: $e');
    }
  }

  static Future<void> downloadAllStudentsExcel() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/export/all/excel'),
      );
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '전체학생_성적표.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      throw Exception('Excel 다운로드 실패: $e');
    }
  }

  static Future<List<dynamic>> getAllSubmissions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grading/submissions'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getSubmissionDetail(String submissionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/grading/submissions/$submissionId'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load submission detail');
    }
  }

  static Future<bool> gradeAnswer({
    required String answerId,
    required int pointsEarned,
    required bool isCorrect,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/grading/answers/$answerId/grade'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pointsEarned': pointsEarned,
          'isCorrect': isCorrect,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getWorksheetSubmissions(String worksheetId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/grading/worksheet/$worksheetId/submissions'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return [];
    }
  }
}
