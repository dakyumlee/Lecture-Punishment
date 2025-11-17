class Worksheet {
  final String id;
  final String title;
  final String? description;
  final String? pdfUrl;
  final int totalQuestions;

  Worksheet({
    required this.id,
    required this.title,
    this.description,
    this.pdfUrl,
    required this.totalQuestions,
  });

  factory Worksheet.fromJson(Map<String, dynamic> json) {
    return Worksheet(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pdfUrl: json['pdfUrl'],
      totalQuestions: json['totalQuestions'] ?? 0,
    );
  }
}
 