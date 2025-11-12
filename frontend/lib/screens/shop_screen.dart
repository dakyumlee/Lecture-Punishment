import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class ShopScreen extends StatefulWidget {
  final Student student;

  const ShopScreen({super.key, required this.student});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<dynamic> _items = [];
  Map<String, List<dynamic>> _groupedItems = {};
  bool _isLoading = true;
  String _selectedTab = 'outfit';
  int _currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadInventory();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getShopItems();
      setState(() {
        _items = data['items'] ?? [];
        _groupedItems = Map<String, List<dynamic>>.from(
          (data['groupedItems'] as Map).map(
            (key, value) => MapEntry(key.toString(), List<dynamic>.from(value)),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _loadInventory() async {
    try {
      final data = await ApiService.getStudentInventory(widget.student.id);
      setState(() {
        _currentPoints = data['points'] ?? widget.student.points;
      });
    } catch (e) {
      print('인벤토리 로드 실패: $e');
    }
  }

  Future<void> _buyItem(String itemId, String itemName, int price) async {
    if (_currentPoints < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포인트가 부족합니다')),
      );
      return;
    }

    try {
      final result = await ApiService.buyItem(
        studentId: widget.student.id,
        itemId: itemId,
      );
      
      setState(() {
        _currentPoints = result['remainingPoints'];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$itemName 구매 완료!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00010D),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '상점',
              style: TextStyle(
                fontFamily: 'JoseonGulim',
                color: Color(0xFFD9D4D2),
              ),
            ),
            Row(
              children: [
                const Text(
                  '💰',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_currentPoints P',
                  style: const TextStyle(
                    fontFamily: 'JoseonGulim',
                    color: Color(0xFFD9D4D2),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton('옷', 'outfit'),
                const SizedBox(width: 8),
                _buildTabButton('😊 표정', 'expression'),
                const SizedBox(width: 8),
                _buildTabButton('🔨 소모품', 'consumable'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD9D4D2),
                    ),
                  )
                : _buildItemGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTab = value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF595048)
              : const Color(0xFF0D0D0D),
          foregroundColor: const Color(0xFFD9D4D2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF736A63)
                  : const Color(0xFF595048),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'JoseonGulim',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildItemGrid() {
    final items = _groupedItems[_selectedTab] ?? [];
    
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '아이템이 없습니다',
          style: TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    final name = item['name'] ?? '';
    final price = item['price'] ?? 0;
    final description = item['description'] ?? '';
    final imageUrl = item['imageUrl'];
    final id = item['id'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF595048)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00010D),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            '🎨',
                            style: TextStyle(fontSize: 48),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        '🎨',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF736A63),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _buyItem(id, name, price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595048),
                    foregroundColor: const Color(0xFFD9D4D2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    '$price P',
                    style: const TextStyle(
                      fontFamily: 'JoseonGulim',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
