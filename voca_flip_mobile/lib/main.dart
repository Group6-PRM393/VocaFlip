import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/features/splash/splash_screen.dart';
import 'package:voca_flip_mobile/features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const VocaFlipApp(),
    ),
  );
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
      home: const SplashScreen(),
    );
  }
}

