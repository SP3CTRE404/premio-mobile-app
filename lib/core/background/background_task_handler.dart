import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../notifications/notification_service.dart';
import '../secure_storage/secure_storage_service.dart';
import '../../features/subscriptions/models/subscription_model.dart';
import '../../features/account/models/user_model.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final container = ProviderContainer();
    try {
      final storage = container.read(secureStorageServiceProvider);
      final userId = await storage.getUserId();
      
      if (userId == null) return true;

      final apiClient = container.read(apiClientProvider);
      await apiClient.warmUpToken();

      // Fetch the freshest profile to get the correct currency from backend
      final profileResponse = await apiClient.dio.get('/api/users/profile');
      final user = User.fromJson(profileResponse.data);
      final String currency = user.currencySymbol;

      final response = await apiClient.dio.get(ApiEndpoints.allSubscriptions(userId));
      final List<dynamic> data = response.data;
      final subscriptions = data.map((json) => Subscription.fromJson(json)).toList();

      final notificationService = NotificationService();
      await notificationService.init();

      for (var sub in subscriptions) {
        String? title;
        String? message;
        final String priceInfo = "$currency${sub.amount.toStringAsFixed(2)}";

        if (sub.isAutoPay) {
          // Auto-Pay Logic
          if (sub.daysUntilDue == 1) {
            title = "Renewal Reminder";
            message = "${sub.serviceName} ($priceInfo) will be automatically renewed tomorrow!";
          } else if (sub.daysUntilDue == 0) {
            title = "Subscription Renewed";
            message = "Your ${sub.serviceName} ($priceInfo) subscription has been renewed today!";
          }
        } else {
          // Manual-Pay Logic
          if (sub.isUpcoming) {
            title = "Payment Reminder";
            message = "${sub.serviceName} ($priceInfo) is due in ${sub.daysUntilDue} days. Please pay manually.";
          } else if (sub.isOverdue) {
            title = "OVERDUE ALERT";
            message = "${sub.serviceName} ($priceInfo) is overdue! Please complete your payment.";
          }
        }

        if (title != null && message != null) {
          await notificationService.showNotification(
            id: sub.id,
            title: title,
            body: message,
          );
        }
      }
      return true;
    } catch (e) {
      // Log error or handle it
      return false;
    } finally {
      container.dispose();
    }
  });
}

class BackgroundTaskHandler {
  static const String taskName = "subscriptionCheckTask";

  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> scheduleDailyTask() async {
    await Workmanager().registerPeriodicTask(
      "1",
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 7, 59);
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    return scheduledTime.difference(now);
  }
}
