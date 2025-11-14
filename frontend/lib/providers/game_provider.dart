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
  bool _needsProfile = false;

  Student? get currentStudent => _currentStudent;
  Instructor? get currentInstructor => _currentInstructor;
  Boss? get currentBoss => _currentBoss;
  List<Quiz> get quizzes => _quizzes;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  bool get needsProfile => _needsProfile;

  Future<void> loginStudent(String username) async {
    try {
      final result = await _apiService.studentLogin(username);
      _currentStudent = Student.fromJson(result['student']);
      _needsProfile = result['needsProfile'] ?? false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeProfile({
    String? birthDate,
    String? phoneNumber,
    String? studentIdNumber,
  }) async {
    if (_currentStudent == null) return;
    
    _currentStudent = await _apiService.completeProfile(
      studentId: _currentStudent!.id,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
      studentIdNumber: studentIdNumber,
    );
    _needsProfile = false;
    notifyListeners();
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
