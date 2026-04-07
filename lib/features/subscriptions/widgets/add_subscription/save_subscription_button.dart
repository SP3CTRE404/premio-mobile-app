import 'package:flutter/material.dart';

class SaveSubscriptionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? text;

  const SaveSubscriptionButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: isLoading
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
          : Text(text ?? 'Save Subscription', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
