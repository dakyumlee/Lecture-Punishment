import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExpressionPicker extends StatelessWidget {
  final String studentId;
  final String currentExpression;
  final Function(String) onExpressionChanged;

  const ExpressionPicker({
    super.key,
    required this.studentId,
    required this.currentExpression,
    required this.onExpressionChanged,
  });

  Future<void> _changeExpression(BuildContext context, String expression) async {
    try {
      await ApiService.changeExpression(studentId, expression);
      onExpressionChanged(expression);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('표정이 변경되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('표정 변경 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expressions = ['😊', '😭', '😎', '😈', '😐', '🤔', '😤', '😱'];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: expressions.map((expression) {
        final isSelected = expression == currentExpression;
        return GestureDetector(
          onTap: () => _changeExpression(context, expression),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF595048) : const Color(0xFF0D0D0D),
              border: Border.all(
                color: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF595048),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                expression,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}