import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Helper to get consistent icons and colors for subscriptions based on their names.
class SubscriptionUIHelper {
  static IconData getIcon(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('youtube') ||
        lower.contains('netflix') ||
        lower.contains('prime') ||
        lower.contains('disney')) {
      return Icons.play_circle_fill_rounded;
    }
    if (lower.contains('amazon') ||
        lower.contains('ebay') ||
        lower.contains('cart')) {
      return Icons.shopping_cart_rounded;
    }
    if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('music')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('gym') || lower.contains('fitness')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('cloud') ||
        lower.contains('drive') ||
        lower.contains('icloud')) {
      return Icons.cloud_rounded;
    }
    if (lower.contains('microsoft') || lower.contains('365') || lower.contains('office')) {
      return Icons.description_rounded;
    }
    if (lower.contains('playstation') || lower.contains('xbox') || lower.contains('games')) {
      return Icons.games_rounded;
    }
    if (lower.contains('zomato') || lower.contains('swiggy') || lower.contains('food')) {
      return Icons.restaurant_rounded;
    }
    return Icons.subscriptions_rounded;
  }

  static Color getStatusColor(DateTime nextBillingDate, {bool isDark = false}) {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.redAccent;
    }
    if (difference <= 7) {
      return Colors.orangeAccent;
    }
    return AppColors.cobaltBlue;
  }

  static String getDueStatus(DateTime nextBillingDate) {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue by ${difference.abs()} days';
    }
    if (difference == 0) {
      return 'Due today';
    }
    if (difference <= 7) {
      return 'Due in $difference days';
    }
    return 'Upcoming';
  }
}

