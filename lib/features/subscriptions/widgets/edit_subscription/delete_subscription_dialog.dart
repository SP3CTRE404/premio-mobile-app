import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toast.dart';

class DeleteSubscriptionDialog extends ConsumerStatefulWidget {
  final Subscription sub;

  const DeleteSubscriptionDialog({
    super.key,
    required this.sub,
  });

  @override
  ConsumerState<DeleteSubscriptionDialog> createState() => _DeleteSubscriptionDialogState();
}

class _DeleteSubscriptionDialogState extends ConsumerState<DeleteSubscriptionDialog> {
  bool _isLoading = false;

  Future<void> _handleDelete() async {
    // Authenticate
    final authenticated = await ref.read(authServiceProvider).authenticate();
    
    if (!authenticated) return;

    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      await ref.read(subscriptionProvider.notifier).delete(widget.sub.id);
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        CustomToast.show(
          context: context, 
          message: '${widget.sub.serviceName} deleted permanently', 
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context: context, 
          message: 'Failed to delete: $e', 
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
      title: const Text('Delete Subscription?'),
      content: Text(
        'Are you sure you want to permanently delete your "${widget.sub.serviceName}" subscription? '
        'All the payment history will be lost. This action cannot be undone.'
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleDelete,
          style: TextButton.styleFrom(foregroundColor: AppColors.neonRed),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
            : const Text('Delete Forever'),
        ),
      ],
    );
  }
}
