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
}
