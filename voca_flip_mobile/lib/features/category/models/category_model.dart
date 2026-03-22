class CategoryModel {
  final String id;
  final String categoryName;
  final String iconCode;
  final String colorHex;
  final int deckCount;

  CategoryModel({
    required this.id, 
    required this.categoryName,
    required this.iconCode,
    required this.colorHex,
    this.deckCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      categoryName: (json['categoryName'] ?? json['category_name'] ?? json['name'] ?? '').toString(),
      iconCode: (json['iconCode'] ?? json['icon_code'] ?? 'folder').toString(),
      colorHex: (json['colorHex'] ?? json['color_hex'] ?? '#135BEC').toString(),
      deckCount: json['deckCount'] ?? json['deck_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'iconCode': iconCode,
      'colorHex': colorHex,
    };
  }
}
