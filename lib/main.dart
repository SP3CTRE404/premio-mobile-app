import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SubTrackApp(),
    ),
  );
}

class SubTrackApp extends StatelessWidget {
  const SubTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubTrack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switch based on system
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
// fj