  static Future<Map<String, dynamic>> submitWorksheet({
    required String worksheetId,
    required String studentId,
    required List<Map<String, String>> answers,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'answers': answers}),
    );
    return jsonDecode(response.body);
  }
    final response = await http.post(
      Uri.parse('$baseUrl/worksheets/$worksheetId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'answers': answers}),
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
    final response = await http.get(Uri.parse('$baseUrl/submissions'));
    return jsonDecode(response.body) as List;
  }

  static Future<Map<String, dynamic>> getSubmissionDetail(String submissionId) async {
    final response = await http.get(Uri.parse('$baseUrl/submissions/$submissionId'));
    return jsonDecode(response.body);
  }

  static Future<bool> gradeAnswer(String answerId, bool isCorrect, int score) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submissions/answers/$answerId/grade'),
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
}
