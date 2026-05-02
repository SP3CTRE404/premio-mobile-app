import 'package:flutter/material.dart';
import '../../screens/expired_subscriptions_screen.dart';

class ManagementCard extends StatelessWidget {
  const ManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Column(
      children: [
        _buildItem(
          context,
          icon: Icons.unsubscribe_rounded,
          title: 'Expired Subscriptions',
          subtitle: 'View and reactivate past plans',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExpiredSubscriptionsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
