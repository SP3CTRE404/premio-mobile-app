import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
  }) {
    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        isError: isError,
        onDismissed: () {
          if (overlayEntry != null && overlayEntry!.mounted) {
            overlayEntry!.remove();
            overlayEntry = null;
          }
        },
      ),
    );

    overlayState.insert(overlayEntry!);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _showToast();
  }

  Future<void> _showToast() async {
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError 
        ? AppColors.neonRed.withValues(alpha: 0.9) 
        : const Color(0xFF333333).withValues(alpha: 0.85);
    final onColor = Colors.white;

    return Positioned(
      bottom: 80.0,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _opacity,
            child: Container(
               margin: const EdgeInsets.symmetric(horizontal: 32.0),
               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
               decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20.0),
               ),
               child: Text(
                 widget.message,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: onColor, 
                   fontSize: 13.0,
                   fontWeight: FontWeight.w500,
                 ),
               ),
            ),
          ),
        ),
      ),
    );
  }
}
