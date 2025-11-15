import 'package:flutter/material.dart';
import '../models/instructor.dart';
import '../models/quiz.dart';
import '../models/boss.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  Instructor? _currentInstructor;
  Boss? _currentBoss;
  Student? _currentStudent;
  List<Quiz> _quizzes = [];
  int _correctCount = 0;
  int _wrongCount = 0;

  Instructor? get currentInstructor => _currentInstructor;
  Boss? get currentBoss => _currentBoss;
  Student? get currentStudent => _currentStudent;
  List<Quiz> get quizzes => _quizzes;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;

  Future<void> studentLogin(String name, {String? birthDate, String? phoneNumber}) async {
    final Map<String, String> requestBody = {'username': name};
    
    if (birthDate != null && birthDate.isNotEmpty) {
      requestBody['birthDate'] = birthDate;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      requestBody['phoneNumber'] = phoneNumber;
    }

    final response = await ApiService.login(name, birthDate ?? '');
    
    if (response['success'] == true && response['student'] != null) {
      _currentStudent = Student.fromJson(response['student']);
      notifyListeners();
    } else if (response['hasDuplicates'] == true) {
      throw Exception('동명이인');
    } else {
      throw Exception(response['message'] ?? '로그인 실패');
    }
  }

  Future<void> completeProfile({String? birthDate, String? phoneNumber}) async {
    if (_currentStudent == null) return;

    try {
      final response = await ApiService.completeProfile(
        studentId: _currentStudent!.id,
        birthDate: birthDate,
        phoneNumber: phoneNumber,
      );

      if (response['success'] == true && response['student'] != null) {
        _currentStudent = Student.fromJson(response['student']);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('프로필 완성 실패: $e');
    }
  }

  Future<Map<String, dynamic>> getMyPageData() async {
    if (_currentStudent == null) {
      return {
        'badges': [],
        'recentActivities': [],
        'stats': {},
      };
    }

    try {
      final data = await ApiService.getMyPageData(_currentStudent!.id);
      return data;
    } catch (e) {
      return {
        'badges': [],
        'recentActivities': [],
        'stats': {},
      };
    }
  }

  Future<void> loadInstructor(String name) async {
    notifyListeners();
  }

  Future<void> loadTodayDungeon() async {
    final bosses = await ApiService.getBosses();
    if (bosses.isNotEmpty) {
      _currentBoss = bosses.first;
      _quizzes = await ApiService.getQuizzes(_currentBoss!.id);
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String quizId, String answer) async {
    _correctCount++;
    notifyListeners();
  }

  void reset() {
    _correctCount = 0;
    _wrongCount = 0;
    notifyListeners();
  }
}
