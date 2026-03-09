class MaterialItem {
  final String id;
  final String name;
  final String unit;
  final int price;
  final String? imageUrl;
  final String? category;

  MaterialItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.imageUrl,
    this.category,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      price: json['price_per_unit_inr'],
      // We'll map IDs to placeholder URLs or local assets in the UI
      imageUrl: null, 
    );
  }
}
