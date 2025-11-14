import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/instructor.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Student? _currentStudent;
  Instructor? _currentInstructor;
  
  Student? get currentStudent => _currentStudent;
  Instructor? get currentInstructor => _currentInstructor;

  Future<void> studentLogin(String name, {String? birthDate, String? phoneNumber}) async {
    final result = await _apiService.studentLogin(name, birthDate: birthDate, phoneNumber: phoneNumber);
    _currentStudent = result['student'];
    notifyListeners();
  }

  Future<void> instructorLogin(String username, String password) async {
    final result = await _apiService.adminLogin(username, password);
    if (result['success'] == true && result['instructor'] != null) {
      _currentInstructor = result['instructor'];
      notifyListeners();
    } else {
      throw Exception('로그인 실패');
    }
  }

  Future<void> completeProfile({String? birthDate, String? phoneNumber}) async {
    if (_currentStudent == null) return;
    
    _currentStudent = await _apiService.completeProfile(
      _currentStudent!.id,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>> getMyPageData() async {
    if (_currentStudent == null) {
      throw Exception('로그인이 필요합니다');
    }
    return await _apiService.getMyPageData(_currentStudent!.id);
  }

  void logout() {
    _currentStudent = null;
    _currentInstructor = null;
    notifyListeners();
  }
}
