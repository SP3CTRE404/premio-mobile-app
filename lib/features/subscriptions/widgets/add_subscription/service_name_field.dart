import 'package:flutter/material.dart';
import 'subscription_field_decoration.dart';

class ServiceNameField extends StatelessWidget {
  final TextEditingController controller;

  const ServiceNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      style: theme.textTheme.bodyLarge,
      decoration: themedDecoration(theme, 'e.g. Netflix, Gym', Icons.subscriptions_outlined),
      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
    );
  }
}
