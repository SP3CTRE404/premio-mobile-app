import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';
import 'subscription_field_decoration.dart';

class BillingCycleField extends StatelessWidget {
  final BillingCycle? selectedCycle;
  final ValueChanged<BillingCycle> onSelected;

  const BillingCycleField({
    super.key,
    required this.selectedCycle,
    required this.onSelected,
  });

  String? _getCycleLabel(BillingCycle? cycle) {
    if (cycle == null) return null;
    return cycle == BillingCycle.monthly
        ? 'Monthly'
        : cycle == BillingCycle.quarterly
            ? 'Every 3 Months'
            : cycle == BillingCycle.yearly
                ? 'Yearly'
                : cycle == BillingCycle.custom
                    ? 'Custom Interval'
                    : 'One-time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = _getCycleLabel(selectedCycle);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Theme(
          data: theme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            popupMenuTheme: theme.popupMenuTheme.copyWith(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
            ),
          ),
          child: PopupMenuButton<BillingCycle>(
            onSelected: onSelected,
            offset: Offset(constraints.maxWidth, 60),
            tooltip: 'Select Cycle',
            itemBuilder: (context) => {
              BillingCycle.monthly: 'Monthly',
              BillingCycle.quarterly: 'Every 3 Months',
              BillingCycle.yearly: 'Yearly',
              BillingCycle.custom: 'Custom Interval',
              BillingCycle.oneTime: 'One-time',
            }.entries.map((entry) {
              final isSelected = entry.key == selectedCycle;
              return PopupMenuItem<BillingCycle>(
                value: entry.key,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 18),
                  ],
                ),
              );
            }).toList(),
            child: IgnorePointer(
              child: TextFormField(
                key: ValueKey(displayValue),
                initialValue: displayValue,
                decoration: themedDecoration(theme, 'Select Cycle', Icons.autorenew_rounded).copyWith(
                  suffixIcon: Icon(Icons.expand_more_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
                validator: (_) => displayValue == null ? 'Required' : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
