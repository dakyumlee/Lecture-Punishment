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
  List<String> _ownedItemIds = [];
  bool _isLoading = true;
  String _selectedTab = 'expression';
  int _currentPoints = 0;
  String? _currentExpression;
  String? _currentOutfit;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.student.points ?? 0;
    _currentExpression = widget.student.characterExpression;
    _currentOutfit = widget.student.characterOutfit;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final items = await ApiService.getShopItems();
      final inventory = await ApiService.getStudentInventory(widget.student.id);
      
      List<String> ownedIds = [];
      if (inventory['items'] != null) {
        for (var item in inventory['items']) {
          ownedIds.add(item['id'].toString());
        }
      }
      
      setState(() {
        _itemsData = items;
        _ownedItemIds = ownedIds;
        _currentPoints = inventory['points'] ?? _currentPoints;
        _currentExpression = inventory['characterExpression'] ?? _currentExpression;
        _currentOutfit = inventory['characterOutfit'] ?? _currentOutfit;
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

  Future<void> _buyItem(String itemId, String itemName, int price) async {
    if (_ownedItemIds.contains(itemId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 구매한 아이템입니다')),
      );
      return;
    }
    
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
      
      if (result['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$itemName 구매 완료!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 실패: $e')),
        );
      }
    }
  }

  Future<void> _applyItem(String itemId, String itemType, String imageUrl) async {
    try {
      await ApiService.changeExpression(widget.student.id, imageUrl);
      
      setState(() {
        if (itemType == 'expression') {
          _currentExpression = imageUrl;
        } else if (itemType == 'outfit') {
          _currentOutfit = imageUrl;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('적용 완료!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('적용 실패: $e')),
        );
      }
    }
  }

  bool _isEmoji(String? text) {
    if (text == null || text.isEmpty) return false;
    final runes = text.runes;
    return runes.length == 1 && runes.first > 0x1F300;
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
    return Scaffold(
      backgroundColor: const Color(0xFF00010D),
      appBar: AppBar(
        title: const Text(
          '상점',
          style: TextStyle(fontFamily: 'JoseonGulim', color: Color(0xFFD9D4D2)),
        ),
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
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD9D4D2)),
                  )
                : _buildItemGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedTab = value),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedTab == value
                ? const Color(0xFF595048)
                : const Color(0xFF0D0D0D),
            foregroundColor: const Color(0xFFD9D4D2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: _selectedTab == value
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
      ),
    );
  }

  Widget _buildItemGrid() {
    final allItems = _itemsData['items'] as List? ?? [];
    final items = allItems
        .where((item) => item['itemType'] == _selectedTab)
        .toList();
    
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
        childAspectRatio: 0.75,
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
    final id = item['id'].toString();
    final name = item['name'] ?? '';
    final description = item['description'] ?? '';
    final price = item['price'] ?? 0;
    final imageUrl = item['imageUrl'];
    final itemType = item['itemType'];
    final isOwned = _ownedItemIds.contains(id);
    final isApplied = _isApplied(itemType, imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF595048),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApplied
              ? Colors.green
              : isOwned
                  ? const Color(0xFF736A63)
                  : const Color(0xFF595048),
          width: isApplied ? 3 : 1,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: _isEmoji(imageUrl)
                        ? Text(
                            imageUrl ?? '🎨',
                            style: const TextStyle(fontSize: 60),
                          )
                        : const Icon(
                            Icons.image,
                            size: 60,
                            color: Color(0xFF736A63),
                          ),
                  ),
                ),
                if (isApplied)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '적용중',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'JoseonGulim',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isOwned && !isApplied)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF736A63),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '소유중',
                        style: TextStyle(
                          color: Color(0xFFD9D4D2),
                          fontFamily: 'JoseonGulim',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                const SizedBox(height: 8),
                if (isOwned && !isApplied)
                  ElevatedButton(
                    onPressed: () => _applyItem(id, itemType, imageUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      '적용',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'JoseonGulim',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (!isOwned)
                  ElevatedButton(
                    onPressed: () => _buyItem(id, name, price),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D0D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
