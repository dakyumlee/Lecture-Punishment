import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/instructor.dart';
import '../models/quiz.dart';
import '../models/boss.dart';
import '../models/worksheet.dart';
import '../models/shop_item.dart';

class ApiService {
  static const String baseUrl = 'https://lecture-punishment-production.up.railway.app';

  Future<Map<String, dynamic>> studentLogin(String name, {String? birthDate, String? phoneNumber}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/student/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        if (birthDate != null) 'birthDate': birthDate,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        'student': Student.fromJson(data['student']),
        'isProfileComplete': data['isProfileComplete'] ?? true,
      };
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['message'] ?? '로그인 실패');
    }
  }

  Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/instructor/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        'success': data['success'],
        'instructor': data['instructor'] != null ? Instructor.fromJson(data['instructor']) : null,
      };
    }
    throw Exception('관리자 로그인 실패');
  }

  Future<Student> completeProfile(String studentId, {String? birthDate, String? phoneNumber, String? studentIdNumber}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/students/$studentId/complete-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (birthDate != null) 'birthDate': birthDate,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (studentIdNumber != null) 'studentIdNumber': studentIdNumber,
      }),
    );

    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('프로필 완성 실패');
  }

  Future<Student> getStudent(String studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/students/$studentId'));
    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('학생 정보 조회 실패');
  }

  Future<Map<String, dynamic>> getMyPageData(String studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/students/$studentId/mypage'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('마이페이지 데이터 조회 실패');
  }

  Future<List<Quiz>> getQuizzes(String bossId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/quizzes/boss/$bossId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Quiz.fromJson(json)).toList();
    }
    throw Exception('퀴즈 조회 실패');
  }

  Future<Map<String, dynamic>> submitAnswer(String submissionId, String answer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/submissions/$submissionId/answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'answer': answer}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('답안 제출 실패');
  }

  Future<List<Boss>> getBosses() async {
    final response = await http.get(Uri.parse('$baseUrl/api/bosses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Boss.fromJson(json)).toList();
    }
    throw Exception('보스 조회 실패');
  }

  Future<List<Worksheet>> getWorksheets() async {
    final response = await http.get(Uri.parse('$baseUrl/api/worksheets'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Worksheet.fromJson(json)).toList();
    }
    throw Exception('문제지 조회 실패');
  }

  Future<List<ShopItem>> getShopItems() async {
    final response = await http.get(Uri.parse('$baseUrl/api/shop/items'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => ShopItem.fromJson(json)).toList();
    }
    throw Exception('상점 아이템 조회 실패');
  }

  Future<Map<String, dynamic>> purchaseItem(String studentId, String itemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/shop/purchase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'itemId': itemId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('아이템 구매 실패');
  }

  Future<List<Map<String, dynamic>>> getRankings() async {
    final response = await http.get(Uri.parse('$baseUrl/api/students/rankings'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('랭킹 조회 실패');
  }
}
