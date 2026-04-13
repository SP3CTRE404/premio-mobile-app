import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  static Color getStatusColor({
    required bool isOverdue,
    required bool isUpcoming,
    bool isDark = false,
  }) {
    if (isOverdue) {
      return Colors.redAccent;
    }
    if (isUpcoming) {
      return Colors.orangeAccent;
    }
    return AppColors.cobaltBlue;
  }

  static String getDueStatus({
    required bool isOverdue,
    required bool isUpcoming,
    required int daysUntilDue,
  }) {
    if (isOverdue) {
      return 'Overdue by ${daysUntilDue.abs()} days';
    }
    if (daysUntilDue == 0) {
      return 'Due today';
    }
    if (isUpcoming) {
      return 'Due in $daysUntilDue days';
    }
    return 'Upcoming';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}


