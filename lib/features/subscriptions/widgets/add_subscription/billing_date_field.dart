import 'package:flutter/material.dart';
import 'subscription_field_decoration.dart';

class BillingDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const BillingDateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = selectedDate == null
        ? null
        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextFormField(
          key: ValueKey(displayValue),
          initialValue: displayValue,
          decoration: themedDecoration(theme, 'Tap to select date', Icons.calendar_today_rounded).copyWith(
            suffixIcon: Icon(Icons.expand_more_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ),
          validator: (_) => displayValue == null ? 'Required' : null,
        ),
      ),
    );
  }
}
