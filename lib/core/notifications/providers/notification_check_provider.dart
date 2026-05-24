import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../notification_service.dart';

final notificationCheckProvider = Provider.autoDispose<NotificationCheckService>((ref) {
  final service = NotificationCheckService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

class NotificationCheckService with WidgetsBindingObserver {
  final Ref _ref;
  Timer? _timer;
  bool _isChecking = false;

  NotificationCheckService(this._ref) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    // Run initial check
    checkPendingNotifications();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      checkPendingNotifications();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPendingNotifications();
    }
  }

  Future<void> checkPendingNotifications() async {
    final authStatus = _ref.read(authProvider);
    if (authStatus != AuthStatus.authenticated) return;

    if (_isChecking) return;
    _isChecking = true;

    try {
      final client = _ref.read(apiClientProvider);
      
      // Fetch pending notifications
      final response = await client.dio.get(ApiEndpoints.pendingNotifications);
      final List<dynamic> data = response.data;
      
      if (data.isEmpty) {
        _isChecking = false;
        return;
      }

      final notificationService = NotificationService();

      for (var item in data) {
        final int id = item['id'];
        final String title = item['title'];
        final String message = item['message'];

        // Determine channel based on title or default
        String channelId = 'premio_reminders_high';
        String channelName = 'Premio Reminders';
        if (title.contains('Member') || title.contains('Household')) {
          channelId = 'premio_household_high';
          channelName = 'Household Updates';
        }

        // 1. Show the local notification
        await notificationService.showNotification(
          id: id,
          title: title,
          body: message,
          channelId: channelId,
          channelName: channelName,
        );

        // 2. Mark as read on the backend
        await client.dio.post(ApiEndpoints.markNotificationRead(id));
      }
    } catch (e) {
      // Quietly log error or ignore if offline/not authenticated yet
    } finally {
      _isChecking = false;
    }
  }
}
