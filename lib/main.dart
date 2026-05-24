import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/navigation/screens/main_scaffold.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/routing/deep_link_handler.dart';
import 'features/navigation/widgets/native_lock_wrapper.dart';

import 'core/notifications/notification_service.dart';
import 'core/background/background_task_handler.dart';

// We use a global navigator key to allow the NativeLockWrapper to 
// bridge system back-button events to the internal Navigator.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notifications
  await NotificationService().init();
  
  // Initialize Background Task Handler
  await BackgroundTaskHandler.init();
  await BackgroundTaskHandler.scheduleDailyTask();

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

    // Listen to AuthStatus changes globally and perform clean navigation transitions
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      final nav = _navigatorKey.currentState;
      if (nav == null) return;

      if (next == AuthStatus.authenticated) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
          (_) => false,
        );
      } else if (next == AuthStatus.unauthenticated || next == AuthStatus.error) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    });

    return MaterialApp(
      title: 'Premio',
      navigatorKey: _navigatorKey, // Providing key to root navigator
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return NativeLockWrapper(
          navigatorKey: _navigatorKey, // Passing key to wrapper
          child: child!,
        );
      },
      home: const DeepLinkHandler(child: SplashScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
