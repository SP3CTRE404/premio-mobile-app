import 'package:flutter/material.dart';

InputDecoration themedDecoration(ThemeData theme, String hint, IconData? icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
    filled: true,
    fillColor: theme.colorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
  );
}
