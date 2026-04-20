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
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime normalizedPurchase = DateTime(purchaseDate.year, purchaseDate.month, purchaseDate.day);
    
    if (cycle == BillingCycle.oneTime) return normalizedPurchase;

    // Logic: If you purchase a subscription, the "next" billing date is at least one cycle away.
    // We start by adding the first cycle to the purchase date.
    DateTime nextDate = _incrementDate(normalizedPurchase, cycle, customDays);

    // If the subscription was purchased so far in the past that the next cycle is still 
    // before today, we keep incrementing until we reach today or a future date.
    int iterations = 0;
    while (nextDate.isBefore(today) && iterations < 1000) {
      nextDate = _incrementDate(nextDate, cycle, customDays);
      iterations++;
    }

    return nextDate;
  }

  static DateTime _incrementDate(DateTime date, BillingCycle cycle, int? customDays) {
    switch (cycle) {
      case BillingCycle.monthly:
        return _addMonths(date, 1);
      case BillingCycle.quarterly:
        return _addMonths(date, 3);
      case BillingCycle.yearly:
        return DateTime(date.year + 1, date.month, date.day);
      case BillingCycle.custom:
        return date.add(Duration(days: customDays ?? 30));
      case BillingCycle.oneTime:
        return date;
    }
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
