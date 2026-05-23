import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;
  late Animation<double> _underlineScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _underlineScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();

    Future.microtask(() async {
      // Warm up the in-memory JWT cache before any API calls
      await ref.read(apiClientProvider).warmUpToken();
      // Enforce the 2-second minimum duration for the splash screen
      await ref.read(authProvider.notifier).checkAuthStatus(
        minDuration: const Duration(seconds: 2),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _textOpacity,
          child: ScaleTransition(
            scale: _textScale,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'SUBTRACK',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900, // Extra-bold tech weight
                      letterSpacing: 4.0, // Wide geometric spacing
                      color: AppColors.cobaltBlue,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  AnimatedBuilder(
                    animation: _underlineScale,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.diagonal3Values(
                            _underlineScale.value, 1.0, 1.0),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 3.5,
                      color: AppColors.cobaltBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
