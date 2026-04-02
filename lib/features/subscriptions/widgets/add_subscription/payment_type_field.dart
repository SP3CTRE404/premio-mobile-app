import 'package:flutter/material.dart';
import 'subscription_field_decoration.dart';

class PaymentTypeField extends StatelessWidget {
  final bool? isAutoPay;
  final ValueChanged<bool> onSelected;

  const PaymentTypeField({
    super.key,
    required this.isAutoPay,
    required this.onSelected,
  });

  String? _getAutoPayLabel(bool? isAutoPay) {
    if (isAutoPay == null) return null;
    return isAutoPay ? 'Auto-pay' : 'Manual';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = _getAutoPayLabel(isAutoPay);

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
          child: PopupMenuButton<bool>(
            onSelected: onSelected,
            offset: Offset(constraints.maxWidth, 60),
            tooltip: 'Select Payment Type',
            itemBuilder: (context) => {
              true: 'Auto-pay',
              false: 'Manual',
            }.entries.map((entry) {
              final isSelected = entry.key == isAutoPay;
              return PopupMenuItem<bool>(
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
                decoration: themedDecoration(theme, 'Select Payment Type', Icons.payment_outlined).copyWith(
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
