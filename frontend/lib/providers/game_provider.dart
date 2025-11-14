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
    final result = await ApiService.login(name, birthDate ?? '');
    if (result['student'] != null) {
      _currentStudent = Student.fromJson(result['student']);
      notifyListeners();
    }
  }

  Future<void> completeProfile({String? birthDate, String? phoneNumber}) async {
    if (_currentStudent != null) {
      _currentStudent = Student(
        id: _currentStudent!.id,
        username: _currentStudent!.username,
        displayName: _currentStudent!.displayName,
        exp: _currentStudent!.exp,
        level: _currentStudent!.level,
        points: _currentStudent!.points,
        isProfileComplete: true,
      );
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getMyPageData() async {
    return {
      'badges': [],
      'recentActivities': [],
      'stats': {},
    };
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
