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

  static Future<Map<String, dynamic>> signup(String displayName, String birthDate, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'displayName': displayName,
        'birthDate': birthDate,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String studentId, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
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

  static Future<Boss> getBoss(String bossId) async {
    final response = await http.get(Uri.parse('$baseUrl/bosses/$bossId'));
    return Boss.fromJson(jsonDecode(response.body));
  }

  static Future<List<Boss>> getBosses() async {
    final response = await http.get(Uri.parse('$baseUrl/bosses'));
    final data = jsonDecode(response.body) as List;
    return data.map((json) => Boss.fromJson(json)).toList();
  }

  static Future<Map<String, dynamic>> addStudentExp(String studentId, int exp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/exp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'exp': exp}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateStudentStats(String studentId, bool isCorrect) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/$studentId/stats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isCorrect': isCorrect}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateBossHp(String bossId, int damage) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bosses/$bossId/hp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'damage': damage}),
    );
    return jsonDecode(response.body);
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
    try {
      final response = await http.get(Uri.parse('$baseUrl/shop/inventory/$studentId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'points': 0, 'items': [], 'characterExpression': '😊', 'characterOutfit': null};
    } catch (e) {
      print('Error fetching inventory: $e');
      return {'points': 0, 'items': [], 'characterExpression': '😊', 'characterOutfit': null};
    }
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
    int? difficulty,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/lessons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title, 
        'description': description,
        'subject': description,
        'groupId': groupId,
        'difficulty': difficulty ?? 3,
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

  static Future<Student> getStudentByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/game/student/$username'));
    return Student.fromJson(jsonDecode(response.body));
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
    try {
      final response = await http.get(Uri.parse('$baseUrl/dungeons/student/$studentId'));
      print('Dungeons API Response: ${response.statusCode}');
      print('Dungeons API Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        throw Exception('Failed to load dungeons: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAvailableDungeons: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getDungeonEntrance(String lessonId) async {
    final response = await http.get(Uri.parse('$baseUrl/dungeons/lesson/$lessonId/entrance'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getInstructor() async {
    final response = await http.get(Uri.parse('$baseUrl/instructor'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getInstructorStats() async {
    final response = await http.get(Uri.parse('$baseUrl/instructor/stats'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addInstructorExp(int exp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/instructor/exp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'exp': exp}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRageDialogue({
    required String dialogueType,
    String? studentName,
    String? question,
    String? wrongAnswer,
    String? correctAnswer,
    int combo = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/rage-dialogue'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dialogueType': dialogueType,
          'studentName': studentName,
          'question': question,
          'wrongAnswer': wrongAnswer,
          'correctAnswer': correctAnswer,
          'combo': combo,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return {
        'dialogue': '복습 좀 해라',
        'dialogueType': dialogueType,
      };
    } catch (e) {
      print('Rage dialogue error: $e');
      return {
        'dialogue': '복습 좀 해라',
        'dialogueType': dialogueType,
      };
    }
  }

  static Future<Map<String, dynamic>> addInstructorRage(int rage) async {
    final response = await http.post(
      Uri.parse('$baseUrl/instructor/rage/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rage': rage}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<Map<String, dynamic>>> getMentalRecoveryMissions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mental-recovery/missions'));
      
      if (response.statusCode == 200) {
        final List<dynamic> missions = jsonDecode(response.body);
        return missions.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching mental recovery missions: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getRandomMentalMission(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mental-recovery/missions/random/$type'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching random mental mission: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> completeMentalMission({
    required String studentId,
    required String missionId,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mental-recovery/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'missionId': missionId,
          'answer': answer,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('Error completing mental mission: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> checkEvolution() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/instructor/evolution/check'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'canEvolve': false};
    } catch (e) {
      print('Error checking evolution: $e');
      return {'canEvolve': false};
    }
  }

  static Future<Map<String, dynamic>> autoEvolve() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/instructor/evolution/auto'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'evolved': false};
    } catch (e) {
      print('Error auto evolving: $e');
      return {'evolved': false};
    }
  }
  
  static Future<Map<String, dynamic>> getRanking({String sortBy = 'points', int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/ranking?sortBy=$sortBy&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'ranking': []};
    } catch (e) {
      print('Error fetching ranking: $e');
      return {'ranking': []};
    }
  }

  static Future<Map<String, dynamic>> generateRaidQuiz({
    required String topic,
    required int difficulty,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/generate-raid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': topic,
          'difficulty': difficulty,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error generating raid quiz: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> checkRaidAnswer({
    required String question,
    required String answer,
    required String correctAnswer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/check-raid-answer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'answer': answer,
          'correctAnswer': correctAnswer,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'isCorrect': false, 'damage': 0};
    } catch (e) {
      print('Error checking raid answer: $e');
      return {'isCorrect': false, 'damage': 0};
    }
  }

  static Future<Map<String, dynamic>> submitQuizResult({
    String? studentId,
    required int correctCount,
    required int totalQuestions,
    String subject = '일반',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/result'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'correctCount': correctCount,
          'totalQuestions': totalQuestions,
          'subject': subject,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {
        'comment': '수고했다',
        'rewards': {'exp': 10, 'points': 100},
        'scorePercent': (correctCount / totalQuestions * 100).toDouble(),
      };
    } catch (e) {
      print('Error submitting quiz result: $e');
      return {
        'comment': '수고했다',
        'rewards': {'exp': 10, 'points': 100},
        'scorePercent': (correctCount / totalQuestions * 100).toDouble(),
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getRageHistory({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/instructor/rage-history?limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching rage history: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMultiverseUniverses(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/multiverse/universes/$studentId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching multiverse universes: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> obtainSoulFragment({
    required String studentId,
    required String multiverseInstructorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/multiverse/fragment/obtain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'multiverseInstructorId': multiverseInstructorId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('Error obtaining soul fragment: $e');
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> getMultiverseProgress(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/multiverse/progress/$studentId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching multiverse progress: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> unlockSpecialEnding(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/multiverse/ending/unlock'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false};
    } catch (e) {
      print('Error unlocking special ending: $e');
      return {'success': false};
    }
  }
}
