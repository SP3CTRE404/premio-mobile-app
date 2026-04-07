import 'package:flutter/material.dart';
import '../../../dashboard/models/mock_data.dart';
import '../../../../core/theme/app_colors.dart';

class EndSubscriptionDialog extends StatelessWidget {
  final MockSub sub;
  final VoidCallback onConfirm;

  const EndSubscriptionDialog({
    super.key,
    required this.sub,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('End Subscription?'),
      content: Text('Are you sure you want to end your ${sub.name} subscription?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.neonRed),
          child: const Text('End Subscription'),
        ),
      ],
    );
  }
}
