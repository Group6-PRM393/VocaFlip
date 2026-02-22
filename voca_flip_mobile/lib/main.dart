import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const VocaFlipApp());
}

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
      home: const Scaffold(body: Center(child: Text('VocaFlip'))),
    );
  }
}
