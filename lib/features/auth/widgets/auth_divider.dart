import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
      ],
    );
  }
}
