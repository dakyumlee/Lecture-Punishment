import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/student.dart';

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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/shop/items'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _items = data['items'] ?? [];
          _groupedItems = Map<String, List<dynamic>>.from(
            (data['groupedItems'] as Map).map(
              (key, value) => MapEntry(key.toString(), List<dynamic>.from(value)),
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _buyItem(String itemId, int price, String itemName) async {
    if (widget.student.points < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포인트가 부족합니다!')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/shop/buy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': widget.student.id,
          'itemId': itemId,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$itemName 구매 완료!')),
            );
            Navigator.pop(context, true);
          }
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '💰 ${widget.student.points}P',
                style: const TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTabButton('outfit', '👕 옷'),
                const SizedBox(width: 8),
                _buildTabButton('expression', '😊 표정'),
                const SizedBox(width: 8),
                _buildTabButton('buff', '⚡ 버프'),
                const SizedBox(width: 8),
                _buildTabButton('consumable', '💊 소모품'),
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

  Widget _buildTabButton(String type, String label) {
    final isSelected = _selectedTab == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'JoseonGulim',
          color: isSelected ? const Color(0xFF00010D) : const Color(0xFFD9D4D2),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFD9D4D2),
      backgroundColor: const Color(0xFF595048),
      onSelected: (selected) {
        setState(() => _selectedTab = type);
      },
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

  Widget _buildItemCard(Map<String, dynamic> item) {
    final price = item['price'] ?? 0;
    final canAfford = widget.student.points >= price;
    final rarity = item['rarity'] ?? 'common';
    
    Color rarityColor;
    switch (rarity) {
      case 'epic':
        rarityColor = Colors.purple;
        break;
      case 'rare':
        rarityColor = Colors.blue;
        break;
      default:
        rarityColor = const Color(0xFF736A63);
    }

    return Card(
      color: const Color(0xFF595048),
      child: InkWell(
        onTap: canAfford
            ? () => _showBuyDialog(item)
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('포인트가 부족합니다!')),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rarityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rarity.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'JoseonGulim',
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item['name'] ?? '',
                style: const TextStyle(
                  color: Color(0xFFD9D4D2),
                  fontFamily: 'JoseonGulim',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['description'] ?? '',
                style: const TextStyle(
                  color: Color(0xFF736A63),
                  fontFamily: 'JoseonGulim',
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$price P',
                    style: TextStyle(
                      color: canAfford ? const Color(0xFFD9D4D2) : Colors.red,
                      fontFamily: 'JoseonGulim',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    canAfford ? Icons.shopping_cart : Icons.lock,
                    color: canAfford ? const Color(0xFFD9D4D2) : Colors.red,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF595048),
        title: Text(
          item['name'],
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
        content: Text(
          '${item['price']}P로 구매하시겠습니까?',
          style: const TextStyle(
            color: Color(0xFFD9D4D2),
            fontFamily: 'JoseonGulim',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF736A63)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _buyItem(item['id'], item['price'], item['name']);
            },
            child: const Text(
              '구매',
              style: TextStyle(color: Color(0xFFD9D4D2)),
            ),
          ),
        ],
      ),
    );
  }
}
