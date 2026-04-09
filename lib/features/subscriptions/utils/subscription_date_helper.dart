import '../models/subscription_model.dart';

class SubscriptionDateHelper {
  /// Calculates the next billing date based on the original purchase date and billing cycle.
  /// If the purchase date is in the past, it iterates forward until it finds the 
  /// first occurrence that is today or in the future.
  static DateTime calculateNextBillingDate(
    DateTime purchaseDate,
    BillingCycle cycle, {
    int? customDays,
  }) {
    final DateTime now = DateTime.now();
    // Normalize to date only (midnight)
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime normalizedPurchase = DateTime(purchaseDate.year, purchaseDate.month, purchaseDate.day);
    
    // If purchase date is today or in the future, that IS the next billing date
    if (!normalizedPurchase.isBefore(today)) {
      return normalizedPurchase;
    }

    DateTime nextDate = normalizedPurchase;

    // Safety counter to prevent infinite loops
    int iterations = 0;
    while (iterations < 1000) {
      DateTime candidate;
      switch (cycle) {
        case BillingCycle.monthly:
          candidate = _addMonths(nextDate, 1);
          break;
        case BillingCycle.quarterly:
          candidate = _addMonths(nextDate, 3);
          break;
        case BillingCycle.yearly:
          candidate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
          break;
        case BillingCycle.custom:
          candidate = nextDate.add(Duration(days: customDays ?? 30));
          break;
      }

      // If the NEXT date is in the future, then the CURRENT nextDate is the one that's due (or was due most recently)
      if (candidate.isAfter(today)) {
        break;
      }

      nextDate = candidate;
      iterations++;
    }

    return nextDate;
  }

  /// Adds months to a date, clamping to the last day of the month if necessary.
  /// e.g., Jan 31 + 1 month = Feb 28 (or 29).
  static DateTime _addMonths(DateTime date, int months) {
    int newMonth = date.month + months;
    int newYear = date.year + (newMonth - 1) ~/ 12;
    newMonth = (newMonth - 1) % 12 + 1;
    
    // Find the last day of the targeted month
    int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    int newDay = date.day > lastDayOfNewMonth ? lastDayOfNewMonth : date.day;
    
    return DateTime(newYear, newMonth, newDay);
  }
}
