import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final bool isUppercase;

  const AppSectionHeader({
    super.key, 
    required this.title,
    this.isUppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: isUppercase 
          ? const EdgeInsets.fromLTRB(20, 12, 20, 4)
          : const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          isUppercase ? title.toUpperCase() : title,
          style: isUppercase
              ? textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                )
              : textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
        ),
      ),
    );
  }
}
