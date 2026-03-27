/// Centralized API route constants.
class ApiEndpoints {
  // ── Auth (public, no token needed) ──
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // ── Subscriptions (protected, token auto-attached) ──
  static String monthlyTotal(int userId) =>
      '/api/subscriptions/user/$userId/monthly-total';

  static String dueSubscriptions(int userId) =>
      '/api/subscriptions/user/$userId/due';

  static const String addSubscription = '/api/subscriptions/add';

  static String paySubscription(int id) => '/api/subscriptions/$id/pay';

  static String toggleAutoPay(int id) => '/api/subscriptions/$id/toggle-autopay';
}
