import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'profile_edit_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Map<String, dynamic>? _myPageData;
  Map<String, dynamic>? _inventoryData;
  bool _isLoading = true;
  String? _currentExpression;
  String? _currentOutfit;

  @override
  void initState() {
    super.initState();
    _loadMyPageData();
  }

  Future<void> _loadMyPageData() async {
    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      if (provider.currentStudent != null) {
        final data = await ApiService.getMyPageData(provider.currentStudent!.id);
        final inventory = await ApiService.getStudentInventory(provider.currentStudent!.id);
        setState(() {
          _myPageData = data;
          _inventoryData = inventory;
          _currentExpression = inventory['characterExpression'];
          _currentOutfit = inventory['characterOutfit'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading my page data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToEditProfile(Student student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileEditScreen(student: student)),
    );
    if (result == true) {
      _loadMyPageData();
    }
  }

  Future<void> _applyItem(String itemId, String itemType, String imageUrl) async {
    try {
      final provider = Provider.of<GameProvider>(context, listen: false);
      await ApiService.changeExpression(provider.currentStudent!.id, imageUrl);
      
      setState(() {
        if (itemType == 'expression') {
          _currentExpression = imageUrl;
        } else if (itemType == 'outfit') {
          _currentOutfit = imageUrl;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('적용 완료!', style: TextStyle(fontFamily: 'JoseonGulim')),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('적용 실패: $e', style: const TextStyle(fontFamily: 'JoseonGulim')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isApplied(String itemType, String? imageUrl) {
    if (itemType == 'expression') {
      return _currentExpression == imageUrl;
    } else if (itemType == 'outfit') {
      return _currentOutfit == imageUrl;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final student = provider.currentStudent;
    if (student == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF00010D),
        appBar: AppBar(
          title: const Text('마이페이지', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
          backgroundColor: const Color(0xFF595048),
          iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        ),
        body: const Center(
          child: Text('로그인이 필요합니다', style: TextStyle(color: Color(0xFF736A63), fontFamily: 'JoseonGulim')),
        ),
      );
    }
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF00010D),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2))),
      );
    }
    final level = _myPageData?['level'] ?? student.level;
    final exp = _myPageData?['exp'] ?? student.exp;
    final points = _myPageData?['points'] ?? student.points;
    final totalCorrect = _myPageData?['totalCorrect'] ?? 0;
    final totalWrong = _myPageData?['totalWrong'] ?? 0;
    final accuracy = totalCorrect + totalWrong > 0 ? (totalCorrect / (totalCorrect + totalWrong) * 100).toStringAsFixed(1) : '0.0';
    
    final purchasedItems = _inventoryData?['items'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF595048),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Center(
                        child: Text(
                          _currentExpression ?? student.characterExpression ?? '😊',
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.displayName,
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '@${student.username}',
                      style: const TextStyle(
                        color: Color(0xFF736A63),
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                title: '게임 스탯',
                children: [
                  _buildInfoRow('레벨', 'Lv. $level'),
                  _buildInfoRow('경험치', '$exp EXP'),
                  _buildInfoRow('포인트', '$points P'),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: '학습 통계',
                children: [
                  _buildInfoRow('정답', '$totalCorrect'),
                  _buildInfoRow('오답', '$totalWrong'),
                  _buildInfoRow('정확도', '$accuracy%'),
                  if (student.birthDate != null)
                    _buildInfoRow('생년월일', student.birthDate.toString()),
                  if (student.phoneNumber != null)
                    _buildInfoRow('휴대폰', student.phoneNumber!),
                  if (student.studentIdNumber != null)
                    _buildInfoRow('학번', student.studentIdNumber!),
                  if (student.birthDate == null && student.phoneNumber == null && student.studentIdNumber == null)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '추가 정보가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: '🛍️ 내 아이템',
                children: [
                  if (purchasedItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '구매한 아이템이 없습니다',
                        style: TextStyle(
                          color: Color(0xFF736A63),
                          fontFamily: 'JoseonGulim',
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: purchasedItems.map((item) {
                        final itemId = item['id'] ?? '';
                        final itemType = item['itemType'] ?? '';
                        final imageUrl = item['imageUrl'] ?? '📦';
                        final name = item['name'] ?? '';
                        final isApplied = _isApplied(itemType, imageUrl);
                        
                        return GestureDetector(
                          onTap: (itemType == 'expression' || itemType == 'outfit') && !isApplied
                              ? () => _applyItem(itemId, itemType, imageUrl)
                              : null,
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0D0D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isApplied ? Colors.green : const Color(0xFF736A63),
                                width: isApplied ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Text(
                                      imageUrl,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    if (isApplied)
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Color(0xFFD9D4D2),
                                    fontFamily: 'JoseonGulim',
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (itemType == 'expression' || itemType == 'outfit') ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    isApplied ? '적용중' : '탭하여 적용',
                                    style: TextStyle(
                                      color: isApplied ? Colors.green : const Color(0xFF736A63),
                                      fontFamily: 'JoseonGulim',
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToEditProfile(student),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595048),
                    foregroundColor: const Color(0xFFD9D4D2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '프로필 편집',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'JoseonGulim',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF736A63)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF736A63),
              fontFamily: 'JoseonGulim',
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
