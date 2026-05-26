import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _rotationController;
  double _pageOffset = 0.0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'TRACK EVERYTHING',
      subtitle: 'FINANCIAL CONSOLIDATION',
      description: 'Consolidate all your monthly and annual subscriptions in one beautiful dashboard. Never lose track of your expenses.',
      icon: Icons.subscriptions_rounded,
      color: AppColors.cobaltBlue,
      meshColors: [AppColors.cobaltBlue, Colors.purple.shade900],
    ),
    OnboardingSlideData(
      title: 'SMART RENEWAL ALERTS',
      subtitle: 'INTELLIGENT TIMING',
      description: 'Get intelligent manual-pay reminders and auto-pay renewal alerts. Avoid unwanted renewals and late fees.',
      icon: Icons.notifications_active_rounded,
      color: Colors.amber.shade500,
      meshColors: [Colors.amber.shade800, Colors.deepOrange.shade900],
    ),
    OnboardingSlideData(
      title: 'HOUSEHOLD BUDGETS',
      subtitle: 'COLLABORATIVE SPENDING',
      description: 'Share subscriptions with your household. Split costs, coordinate budgets, and manage access dynamically.',
      icon: Icons.people_alt_rounded,
      color: Colors.teal.shade400,
      meshColors: [Colors.teal.shade800, Colors.cyan.shade900],
    ),
    OnboardingSlideData(
      title: 'PREMIUM SECURITY',
      subtitle: 'BIOMETRIC LOCK & PIN',
      description: 'Protect your financial data with Biometric face/fingerprint lock or a secure PIN. Your privacy is our priority.',
      icon: Icons.security_rounded,
      color: AppColors.neonRed,
      meshColors: [AppColors.neonRed, Colors.red.shade900],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      });

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveOnboardingCompleted(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    
    final int index = _pageOffset.floor();
    final double fraction = _pageOffset - index;

    // Interpolate background mesh colors dynamically as the user swipes
    final slide1 = _slides[index];
    final slide2 = _slides[(index + 1).clamp(0, _slides.length - 1)];

    final primaryBgColor = Color.lerp(slide1.meshColors[0], slide2.meshColors[0], fraction)!;
    final secondaryBgColor = Color.lerp(slide1.meshColors[1], slide2.meshColors[1], fraction)!;
    final activeThemeColor = Color.lerp(slide1.color, slide2.color, fraction)!;

    final isLastPage = _pageOffset.round() == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Futuristic Shifting Mesh Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.grey.shade900,
            ),
          ),
          
          // Glowing Ambient Orbs
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: _GlowOrb(
              color: primaryBgColor.withValues(alpha: 0.35),
              radius: size.width * 1.1,
            ),
          ),
          Positioned(
            bottom: -size.height * 0.2,
            left: -size.width * 0.3,
            child: _GlowOrb(
              color: secondaryBgColor.withValues(alpha: 0.25),
              radius: size.width * 1.2,
            ),
          ),

          // Technical grid lines overlay
          const Positioned.fill(
            child: _GridOverlay(),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 0.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'PREMIO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      
                      // Skip Button
                      AnimatedOpacity(
                        opacity: isLastPage ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: isLastPage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 0.8,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: _completeOnboarding,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide Builder with Parallax & 3D Transform
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      // Calculate individual slide parallax translation and scale
                      final double position = index - _pageOffset;
                      final double translation = position * size.width * 0.4;
                      final double scale = (1.0 - (position.abs() * 0.15)).clamp(0.8, 1.0);
                      final double opacity = (1.0 - (position.abs() * 0.8)).clamp(0.0, 1.0);
                      final double rotation = position * 0.15;

                      return Opacity(
                        opacity: opacity,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..multiply(Matrix4.translationValues(translation, 0.0, 0.0))
                            ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0))
                            ..rotateY(rotation),
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: size.height * 0.06),
                                  // Rotating HUD graphics container
                                  _FuturisticHud(
                                    icon: slide.icon,
                                    color: slide.color,
                                    rotationAnimation: _rotationController,
                                  ),
                                  SizedBox(height: size.height * 0.08),

                                  // Subtitle tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: slide.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: slide.color.withValues(alpha: 0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      slide.subtitle,
                                      style: TextStyle(
                                        color: slide.color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Title
                                  Text(
                                    slide.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Description
                                  Text(
                                    slide.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Liquid Dot Indicator
                      Row(
                        children: List.generate(
                          _slides.length,
                          (index) => _buildIndicator(index, activeThemeColor),
                        ),
                      ),

                      // Futuristic Circular Action Button
                      _FuturisticButton(
                        isLastPage: isLastPage,
                        activeColor: activeThemeColor,
                        onPressed: () {
                          if (isLastPage) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutQuart,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, Color activeColor) {
    final double distance = (index - _pageOffset).abs();
    final double width = lerpDouble(8.0, 28.0, (1.0 - distance).clamp(0.0, 1.0))!;
    final double opacity = lerpDouble(0.2, 1.0, (1.0 - distance).clamp(0.0, 1.0))!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: width,
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          if (distance < 0.5)
            BoxShadow(
              color: activeColor.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> meshColors;

  OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.meshColors,
  });
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double radius;

  const _GlowOrb({
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.2, 0.8],
        ),
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(
          gridColor: Colors.white.withValues(alpha: 0.02),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const double step = 30.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FuturisticHud extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Animation<double> rotationAnimation;

  const _FuturisticHud({
    required this.icon,
    required this.color,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient circular glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 36,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

          // Outer rotating dashed radar HUD
          AnimatedBuilder(
            animation: rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: rotationAnimation.value * 2 * math.pi,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _HudCirclePainter(color: color.withValues(alpha: 0.4)),
            ),
          ),

          // Counter-rotating tech dial
          AnimatedBuilder(
            animation: rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: -rotationAnimation.value * 4 * math.pi,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(160, 160),
              painter: _HudInnerDialPainter(color: color.withValues(alpha: 0.6)),
            ),
          ),

          // Glassmorphic Center Core
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudCirclePainter extends CustomPainter {
  final Color color;

  _HudCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw dashed outer circle
    double currentAngle = 0;
    const double dashAngle = 0.05;
    const double spaceAngle = 0.08;

    while (currentAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HudInnerDialPainter extends CustomPainter {
  final Color color;

  _HudInnerDialPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw two solid arcs representing a futuristic dial
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 0.4,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * 0.4,
      false,
      paint,
    );

    // Minor decorative dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(center.dx + radius * math.cos(math.pi * 0.6), center.dy + radius * math.sin(math.pi * 0.6)), 2, dotPaint);
    canvas.drawCircle(Offset(center.dx + radius * math.cos(math.pi * 1.6), center.dy + radius * math.sin(math.pi * 1.6)), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FuturisticButton extends StatefulWidget {
  final bool isLastPage;
  final Color activeColor;
  final VoidCallback onPressed;

  const _FuturisticButton({
    required this.isLastPage,
    required this.activeColor,
    required this.onPressed,
  });

  @override
  State<_FuturisticButton> createState() => _FuturisticButtonState();
}

class _FuturisticButtonState extends State<_FuturisticButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.08);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: widget.isLastPage ? 160 : 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: widget.activeColor.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.activeColor,
                      widget.activeColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: widget.isLastPage
                      ? const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
