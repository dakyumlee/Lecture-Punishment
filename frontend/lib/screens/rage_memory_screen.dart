import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RageMemoryScreen extends StatefulWidget {
  const RageMemoryScreen({super.key});
  @override
  State<RageMemoryScreen> createState() => _RageMemoryScreenState();
}

class _RageMemoryScreenState extends State<RageMemoryScreen> {
  List<Map<String, dynamic>> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    try {
      final memories = await ApiService.getRageHistory(limit: 50);
      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('📖 분노의 추억', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty
              ? const Center(child: Text('기록이 없습니다', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _memories.length,
                  itemBuilder: (context, index) {
                    final memory = _memories[index];
                    return Card(
                      color: const Color(0xFF595048),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          memory['dialogueText'] ?? memory['message'] ?? '...',
                          style: const TextStyle(color: Color(0xFFD9D4D2), fontFamily: 'JoseonGulim'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
