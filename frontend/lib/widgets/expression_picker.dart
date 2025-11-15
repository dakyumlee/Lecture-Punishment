import '../services/api_service.dart';
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

  final List<String> expressions = const [
    '😊', '😎', '😂', '🤔', '😴', '😡', 
    '🥳', '😭', '🤯', '😱', '🤓', '😈',
    '💀', '🤡', '👻', '🤖', '👽', '🦄'
  ];

  Future<void> _selectExpression(BuildContext context, String expression) async {
    try {
      await ApiService.changeExpression(
        studentId: studentId,
        expression: expression,
      );
      onExpressionChanged(expression);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('표정이 변경되었습니다: $expression')),
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
    return AlertDialog(
      backgroundColor: const Color(0xFF595048),
      title: const Text(
        '표정 선택',
        style: TextStyle(
          color: Color(0xFFD9D4D2),
          fontFamily: 'JoseonGulim',
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: expressions.length,
          itemBuilder: (context, index) {
            final expression = expressions[index];
            final isSelected = expression == currentExpression;
            
            return GestureDetector(
              onTap: () => _selectExpression(context, expression),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD9D4D2) : const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00010D) : const Color(0xFF736A63),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    expression,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
            ),
          ),
        ),
      ],
    );
  }
}
