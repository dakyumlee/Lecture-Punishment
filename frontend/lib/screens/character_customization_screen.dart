import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class CharacterCustomizationScreen extends StatefulWidget {
  final Student student;

  const CharacterCustomizationScreen({super.key, required this.student});

  @override
  State<CharacterCustomizationScreen> createState() => _CharacterCustomizationScreenState();
}

class _CharacterCustomizationScreenState extends State<CharacterCustomizationScreen> {
  String _selectedExpression = '😐';
  String _selectedOutfit = 'default';
  
  final List<Map<String, dynamic>> _expressions = [
    {'emoji': '😐', 'name': '무표정', 'price': 0},
    {'emoji': '😊', 'name': '미소', 'price': 100},
    {'emoji': '😎', 'name': '쿨함', 'price': 200},
    {'emoji': '🤓', 'name': '공부벌레', 'price': 300},
    {'emoji': '😤', 'name': '투지', 'price': 400},
    {'emoji': '🥺', 'name': '애고', 'price': 500},
    {'emoji': '😈', 'name': '악동', 'price': 600},
    {'emoji': '🤔', 'name': '생각중', 'price': 300},
    {'emoji': '😇', 'name': '천사', 'price': 700},
    {'emoji': '🤯', 'name': '충격', 'price': 500},
  ];

  final List<Map<String, dynamic>> _outfits = [
    {'id': 'default', 'name': '기본 옷', 'icon': Icons.person, 'price': 0, 'color': Color(0xFF595048)},
    {'id': 'student', 'name': '학생복', 'icon': Icons.school, 'price': 500, 'color': Color(0xFF2196F3)},
    {'id': 'hoodie', 'name': '후드티', 'icon': Icons.checkroom, 'price': 800, 'color': Color(0xFF9C27B0)},
    {'id': 'suit', 'name': '정장', 'icon': Icons.business_center, 'price': 1200, 'color': Color(0xFF424242)},
    {'id': 'hero', 'name': '영웅 망토', 'icon': Icons.shield, 'price': 2000, 'color': Color(0xFFFF5722)},
    {'id': 'wizard', 'name': '마법사 로브', 'icon': Icons.auto_awesome, 'price': 2500, 'color': Color(0xFF673AB7)},
  ];

  List<String> _ownedExpressions = ['😐'];
  List<String> _ownedOutfits = ['default'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomization();
  }

  Future<void> _loadCustomization() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get(
        '/student/customization?studentId=${widget.student.id}'
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final ownedItemIds = (data['ownedItemIds'] as List?)?.cast<int>() ?? [];
        
        setState(() {
          _selectedExpression = widget.student.characterExpression ?? '😐';
          _ownedExpressions = ['😐'];
          _ownedOutfits = ['default'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showMessage('커스터마이징 로드 실패: $e', Colors.red);
      }
    }
  }

  Future<void> _purchaseItem(String type, dynamic item) async {
    final price = item['price'] as int;
    
    if (widget.student.points < price) {
      _showMessage('포인트가 부족합니다!', Colors.red);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '구매 확인',
          style: TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '${item['name']}을(를) ${price}P에 구매하시겠습니까?',
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF736A63),
                fontFamily: 'JoseonGulim',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text(
              '구매',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'JoseonGulim',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        widget.student.points -= price;
        if (type == 'expression') {
          _ownedExpressions.add(item['emoji']);
          _selectedExpression = item['emoji'];
        } else {
          _ownedOutfits.add(item['id']);
          _selectedOutfit = item['id'];
        }
      });
      
      _showMessage('구매 완료!', const Color(0xFF4CAF50));
      await _saveCustomization();
    }
  }

  Future<void> _saveCustomization() async {
    try {
      final response = await ApiService.post('/student/customization/apply', {
        'studentId': widget.student.id,
        'customization': {
          'expression': _selectedExpression,
        },
      });

      if (response.statusCode == 200 && mounted) {
        _showMessage('저장되었습니다!', const Color(0xFF4CAF50));
      }
    } catch (e) {
      if (mounted) {
        _showMessage('저장 실패: $e', Colors.red);
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'JoseonGulim'),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF00010D),
        appBar: AppBar(
          title: const Text(
            '🎭 캐릭터 커스터마이징',
            style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
          ),
          backgroundColor: const Color(0xFF595048),
          iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '🎭 캐릭터 커스터마이징',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF736A63),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.student.points}P',
                      style: const TextStyle(
                        color: Color(0xFFD9D4D2),
                        fontFamily: 'JoseonGulim',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(),
            const SizedBox(height: 32),
            _buildSectionTitle('표정 선택'),
            const SizedBox(height: 16),
            _buildExpressionGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle('의상 선택'),
            const SizedBox(height: 16),
            _buildOutfitGrid(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final currentOutfit = _outfits.firstWhere(
      (o) => o['id'] == _selectedOutfit,
      orElse: () => _outfits[0],
    );

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9D4D2), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '미리보기',
            style: TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: currentOutfit['color'],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (currentOutfit['color'] as Color).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              currentOutfit['icon'],
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedExpression,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            widget.student.displayName,
            style: const TextStyle(
              color: Color(0xFFD9D4D2),
              fontFamily: 'JoseonGulim',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFD9D4D2),
        fontFamily: 'JoseonGulim',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExpressionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _expressions.length,
      itemBuilder: (context, index) {
        final expression = _expressions[index];
        final emoji = expression['emoji'] as String;
        final isOwned = _ownedExpressions.contains(emoji);
        final isSelected = _selectedExpression == emoji;

        return GestureDetector(
          onTap: () {
            if (isOwned) {
              setState(() => _selectedExpression = emoji);
            } else {
              _purchaseItem('expression', expression);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF595048),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF736A63),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: isOwned ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                if (!isOwned)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${expression['price']}P',
                        style: const TextStyle(
                          color: Color(0xFF0D0D0D),
                          fontFamily: 'JoseonGulim',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isSelected)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutfitGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _outfits.length,
      itemBuilder: (context, index) {
        final outfit = _outfits[index];
        final id = outfit['id'] as String;
        final isOwned = _ownedOutfits.contains(id);
        final isSelected = _selectedOutfit == id;

        return GestureDetector(
          onTap: () {
            if (isOwned) {
              setState(() => _selectedOutfit = id);
            } else {
              _purchaseItem('outfit', outfit);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF595048),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF736A63),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: outfit['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    outfit['icon'],
                    color: isOwned ? Colors.white : Colors.white.withOpacity(0.3),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  outfit['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isOwned ? const Color(0xFFD9D4D2) : const Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isOwned) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${outfit['price']}P',
                      style: const TextStyle(
                        color: Color(0xFF0D0D0D),
                        fontFamily: 'JoseonGulim',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveCustomization,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          '저장하기',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'JoseonGulim',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
