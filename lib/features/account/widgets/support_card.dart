import 'package:flutter/material.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SupportTile(
          icon: Icons.help_outline_rounded,
          label: 'Help Center',
          onTap: () {},
          showDivider: true,
        ),
        _SupportTile(
          icon: Icons.feedback_outlined,
          label: 'Send Feedback',
          onTap: () {},
          showDivider: false,
        ),
      ],
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _SupportTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 54,
            endIndent: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}