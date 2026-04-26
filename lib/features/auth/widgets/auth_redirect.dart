import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthRedirect extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback onPressed;

  const AuthRedirect({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.cobaltBlue),
          child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
