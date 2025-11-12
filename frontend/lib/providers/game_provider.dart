import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/game_models.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Student? _currentStudent;
  Instructor? _currentInstructor;
  Boss? _currentBoss;
  List<Quiz> _quizzes = [];
  int _correctCount = 0;
  int _wrongCount = 0;

  Student? get currentStudent => _currentStudent;
  Instructor? get currentInstructor => _currentInstructor;
  Boss? get currentBoss => _currentBoss;
  List<Quiz> get quizzes => _quizzes;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;

  Future<void> loginStudent(String username) async {
    try {
      _currentStudent = await _apiService.getStudentByUsername(username);
      _currentStudent ??= await _apiService.createStudent(username, username);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadInstructor(String name) async {
    _currentInstructor = await _apiService.getInstructorByName(name);
    notifyListeners();
  }

  Future<void> loadTodayDungeon() async {
    final lesson = await _apiService.getTodayLesson();
    _currentBoss = await _apiService.getBossByLesson(lesson.id);
    _quizzes = await _apiService.getQuizzesByBoss(_currentBoss!.id);
    _correctCount = 0;
    _wrongCount = 0;
    notifyListeners();
  }

  Future<void> submitAnswer(String quizId, String answer) async {
    if (_currentStudent == null) return;

    final result = await _apiService.submitAnswer(
      _currentStudent!.id,
      quizId,
      answer,
    );

    if (result['isCorrect'] == true) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    await refreshStudent();
    notifyListeners();
  }

  Future<void> refreshStudent() async {
    if (_currentStudent == null) return;
    _currentStudent = await _apiService.getStudent(_currentStudent!.id);
    _currentInstructor = await _apiService.getInstructorByName('허태훈');
    notifyListeners();
  }
}
