import 'package:flutter/material.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Implement Help Center navigation
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO: Implement Send Feedback functionality
            },
          ),
        ],
      ),
    );
  }
}
