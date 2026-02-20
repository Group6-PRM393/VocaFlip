import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'modules/study/study_screen.dart';

void main() {
  runApp(const VocaFlipApp());
}

/// Entry point chính của ứng dụng VocaFlip.
/// Cấu hình Light Theme theo design Stitch.
class VocaFlipApp extends StatelessWidget {
  const VocaFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocaFlip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.scaffoldBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
        ),
      ),
      // Tạm thời mở thẳng StudyScreen để preview Flashcard Front Side
      home: const StudyScreen(),
    );
  }
}
