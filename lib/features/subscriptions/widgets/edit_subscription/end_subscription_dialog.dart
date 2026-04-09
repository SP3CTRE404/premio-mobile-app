import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toast.dart';

class EndSubscriptionDialog extends ConsumerStatefulWidget {
  final Subscription sub;
  final VoidCallback onConfirm;

  const EndSubscriptionDialog({
    super.key,
    required this.sub,
    required this.onConfirm,
  });

  @override
  ConsumerState<EndSubscriptionDialog> createState() => _EndSubscriptionDialogState();
}

class _EndSubscriptionDialogState extends ConsumerState<EndSubscriptionDialog> {
  bool _isLoading = false;

  Future<void> _handleEndSubscription() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(subscriptionProvider.notifier).expire(widget.sub.id);
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        // We notify the parent screen via callback if needed, 
        // but the dialog itself can handle navigation back if preferred.
        // For consistency with user's snippet:
        Navigator.pop(context); // Go back to dashboard/manage screen
        
        CustomToast.show(
          context: context, 
          message: '${widget.sub.serviceName} moved to History', 
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context: context, 
          message: 'Failed to end subscription: $e', 
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('End Subscription?'),
      content: Text('Are you sure you want to end your ${widget.sub.serviceName} subscription?'),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleEndSubscription,
          style: TextButton.styleFrom(foregroundColor: AppColors.neonRed),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
            : const Text('End Subscription'),
        ),
      ],
    );
  }
}


