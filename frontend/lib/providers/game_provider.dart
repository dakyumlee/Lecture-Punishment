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
  bool _isLoading = false;

  Instructor? get currentInstructor => _currentInstructor;
  Boss? get currentBoss => _currentBoss;
  Student? get currentStudent => _currentStudent;
  List<Quiz> get quizzes => _quizzes;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  bool get isLoading => _isLoading;
  int get currentScore => _correctCount;

  void setCurrentStudent(dynamic studentData) {
    _currentStudent = Student.fromJson(studentData);
    notifyListeners();
  }

  Future<void> studentLogin(String name, {String? birthDate, String? phoneNumber}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {'username': name};
      
      if (birthDate != null && birthDate.isNotEmpty) {
        requestBody['birthDate'] = birthDate.replaceAll('-', '');
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestBody['phoneNumber'] = phoneNumber;
      }

      final response = await ApiService.loginWithAuth(requestBody);
      
      if (response['success'] == true && response['student'] != null) {
        _currentStudent = Student.fromJson(response['student']);
      } else if (response['hasDuplicates'] == true) {
        throw Exception('동명이인');
      } else {
        throw Exception(response['message'] ?? '로그인 실패');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> instructorLogin(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.adminLogin(username, password);
      
      if (response['success'] == true && response['instructor'] != null) {
        _currentInstructor = Instructor.fromJson(response['instructor']);
      } else {
        throw Exception(response['message'] ?? '로그인 실패');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeProfile(String studentId, Map<String, String> profileData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.completeProfile(studentId, profileData);

      if (response['success'] == true || response['student'] != null) {
        _currentStudent = Student.fromJson(response['student']);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> loadCurrentBoss() async {
    _isLoading = true;
    notifyListeners();

    try {
      final bosses = await ApiService.getBosses();
      if (bosses.isNotEmpty) {
        _currentBoss = bosses.first;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizzes(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentBoss != null) {
        _quizzes = await ApiService.getQuizzes(_currentBoss!.id);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayDungeon() async {
    _isLoading = true;
    notifyListeners();

    try {
      final bosses = await ApiService.getBosses();
      if (bosses.isNotEmpty) {
        _currentBoss = bosses.first;
        _quizzes = await ApiService.getQuizzes(_currentBoss!.id);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String quizId, String answer) async {
    if (_currentStudent == null) return;

    try {
      final response = await ApiService.submitQuizAnswer(
        quizId: quizId,
        studentId: _currentStudent!.id,
        selectedAnswer: answer,
      );

      if (response['isCorrect'] == true) {
        _correctCount++;
      } else {
        _wrongCount++;
      }

      if (response['student'] != null) {
        _currentStudent = Student.fromJson(response['student']);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void reset() {
    _correctCount = 0;
    _wrongCount = 0;
    notifyListeners();
  }
}
