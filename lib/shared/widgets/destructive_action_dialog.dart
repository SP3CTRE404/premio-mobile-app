import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DestructiveActionDialog extends StatelessWidget {
  final String title;
  final String content;
  final String actionText;
  final VoidCallback onConfirm;
  final bool isLoading;

  const DestructiveActionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actionText,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
        content,
        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: isLoading ? null : () {
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.neonRed,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
            : Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}
