import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// App Info section: version + about description.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: colorScheme.surface,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded,
                  color: AppColors.cobaltBlue),
              title: const Text('App Version'),
              trailing: Text(
                'v1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
