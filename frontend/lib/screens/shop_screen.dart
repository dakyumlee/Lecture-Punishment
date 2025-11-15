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
  Map<String, dynamic> _itemsData = {};
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  String _selectedTab = 'expression';
  int _currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.student.points ?? 0;
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ApiService.getShopItems();
      setState(() {
        _itemsData = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
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
      final result = await ApiService.buyItem(studentId: widget.student.id, itemId: itemId);
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

  bool _isEmoji(String? text) {
    if (text == null || text.isEmpty) return false;
    final runes = text.runes;
    return runes.length == 1 && runes.first > 0x1F300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text('상점', style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2))),
        backgroundColor: const Color(0xFF595048),
        iconTheme: const IconThemeData(color: Color(0xFFD9D4D2)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF595048),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '보유 포인트',
                  style: TextStyle(
                    color: Color(0xFF736A63),
                    fontFamily: 'JoseonGulim',
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$_currentPoints P',
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton('표정', 'expression'),
                _buildTabButton('옷', 'outfit'),
                _buildTabButton('소모품', 'consumable'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD9D4D2)))
                : _buildItemGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTab = value),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedTab == value ? const Color(0xFF595048) : const Color(0xFF0D0D0D),
          foregroundColor: const Color(0xFFD9D4D2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: _selectedTab == value ? const Color(0xFF736A63) : const Color(0xFF595048),
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
    final allItems = _itemsData['items'] as List? ?? [];
    final items = allItems.where((item) => item['itemType'] == _selectedTab).toList();
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '상품이 없습니다',
          style: TextStyle(
            color: Color(0xFF736A63),
            fontFamily: 'JoseonGulim',
            fontSize: 16,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    final id = item['id'];
    final name = item['name'] ?? '';
    final description = item['description'] ?? '';
    final price = item['price'] ?? 0;
    final imageUrl = item['imageUrl'];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF736A63)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: _isEmoji(imageUrl)
                    ? Text(
                        imageUrl ?? '🎨',
                        style: const TextStyle(fontSize: 60),
                      )
                    : const Icon(Icons.image, size: 60, color: Color(0xFF736A63)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFD9D4D2),
                    fontFamily: 'JoseonGulim',
                    fontSize: 14,
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
                    fontFamily: 'JoseonGulim',
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _buyItem(id, name, price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0D0D),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    '$price P',
                    style: const TextStyle(
                      color: Color(0xFFD9D4D2),
                      fontFamily: 'JoseonGulim',
                      fontSize: 14,
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
