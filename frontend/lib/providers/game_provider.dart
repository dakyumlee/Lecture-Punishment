import 'package:flutter/material.dart';
import '../models/instructor.dart';
import '../models/quiz.dart';
import '../models/boss.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  Instructor? _currentInstructor;
  Boss? _currentBoss;
  List<Quiz> _quizzes = [];
  int _correctCount = 0;
  int _wrongCount = 0;

  Instructor? get currentInstructor => _currentInstructor;
  Boss? get currentBoss => _currentBoss;
  List<Quiz> get quizzes => _quizzes;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;

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
