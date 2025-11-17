  void _enterDungeon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          bossId: _entrance?['bossId'],
          student: widget.student,
        ),
      ),
    );
  }
}
