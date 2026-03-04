import 'package:flutter/material.dart';

class CategoryHelper {
  CategoryHelper._(); // Ngăn việc khởi tạo object

  // 1. Chuyển Hex String từ Backend sang Flutter Color
  static Color hexToColor(String hexString) {
    if (hexString.isEmpty) return const Color(0xFF1337EC); // Primary mặc định
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF1337EC);
    }
  }

  // 2. Chuyển Flutter Color sang Hex String gửi lên Backend
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // 3. Chuyển String iconCode từ Backend sang IconData của Flutter
  static IconData getIconFromString(String iconCode) {
    switch (iconCode) {
      case 'menu_book': return Icons.menu_book;
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'flight': return Icons.flight;
      case 'flight_takeoff': return Icons.flight_takeoff; // Mới
      case 'restaurant': return Icons.restaurant;
      case 'forum': return Icons.forum;
      case 'star': return Icons.star;
      case 'flag': return Icons.flag;
      case 'home': return Icons.home; // Mới
      case 'fitness_center': return Icons.fitness_center; // Mới
      case 'shopping_cart': return Icons.shopping_cart; // Mới
      case 'pets': return Icons.pets; // Mới
      default: return Icons.folder;
    }
  }

  // 4. Lấy String từ IconData gửi lên Backend
  static String getStringFromIcon(IconData icon) {
    if (icon == Icons.menu_book) return 'menu_book';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.work) return 'work';
    if (icon == Icons.flight) return 'flight';
    if (icon == Icons.flight_takeoff) return 'flight_takeoff'; // Mới bổ sung
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.forum) return 'forum';
    if (icon == Icons.star) return 'star';
    if (icon == Icons.flag) return 'flag';
    if (icon == Icons.home) return 'home'; // Mới bổ sung
    if (icon == Icons.fitness_center) return 'fitness_center'; // Mới bổ sung
    if (icon == Icons.shopping_cart) return 'shopping_cart'; // Mới bổ sung
    if (icon == Icons.pets) return 'pets'; // Mới bổ sung
    if (icon == Icons.local_cafe) return 'local_cafe';
    return 'folder'; // Giá trị mặc định nếu không khớp cái nào
  }
}