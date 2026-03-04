// class CategoryModel {
//   final String id;
//   final String categoryName;
//   final String iconCode;
//   final String colorHex;
//   final String? userId; // Có thể null khi gửi request tạo mới
//   final int deckCount;

//   CategoryModel({
//     this.id = '',
//     required this.categoryName,
//     required this.iconCode,
//     required this.colorHex,
//     this.userId,
//     this.deckCount = 0,
//   });

//   // Chuyển JSON từ Backend (CategoryResponse) thành Object Dart
//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     return CategoryModel(
//       id: json['id'] ?? '',
//       categoryName: json['categoryName'] ?? '',
//       iconCode: json['iconCode'] ?? '',
//       colorHex: json['colorHex'] ?? '',
//       userId: json['userId'],
//       deckCount: json['deckCount'] ?? 0,
//     );
//   }

//   // Chuyển Object Dart thành JSON (CategoryRequest) để gửi lên Backend
//   Map<String, dynamic> toJson() {
//     return {
//       'categoryName': categoryName,
//       'iconCode': iconCode,
//       'colorHex': colorHex,
//     };
//   }
// }