class ShopItem {
  final String id;
  final String name;
  final String description;
  final String itemType;
  final int price;
  final String rarity;
  final String imageUrl;
  final bool isAvailable;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.itemType,
    required this.price,
    required this.rarity,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      itemType: json['itemType'],
      price: json['price'],
      rarity: json['rarity'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}
