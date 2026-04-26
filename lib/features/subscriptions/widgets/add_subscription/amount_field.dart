import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'subscription_field_decoration.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;

  const AmountField({
    super.key,
    required this.controller,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      decoration: themedDecoration(theme, '0.00', null).copyWith(
        prefixIcon: _buildCurrencyPrefix(theme, currencySymbol),
      ),
      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildCurrencyPrefix(ThemeData theme, String symbol) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            symbol,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
