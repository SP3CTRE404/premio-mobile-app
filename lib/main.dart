import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/settings/providers/theme_provider.dart';
import 'core/routing/deep_link_handler.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SubTrackApp(),
    ),
  );
}

class SubTrackApp extends ConsumerWidget {
  const SubTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SubTrack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DeepLinkHandler(child: SplashScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
