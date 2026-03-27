import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';

/// Immutable state for notification preferences.
class NotificationSettings {
  final bool dueDateAlerts;
  final int reminderLeadDays;

  const NotificationSettings({
    this.dueDateAlerts = false,
    this.reminderLeadDays = 1,
  });

  NotificationSettings copyWith({
    bool? dueDateAlerts,
    int? reminderLeadDays,
  }) {
    return NotificationSettings(
      dueDateAlerts: dueDateAlerts ?? this.dueDateAlerts,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    _loadFromStorage();
    return const NotificationSettings();
  }

  Future<void> _loadFromStorage() async {
    final storage = ref.read(secureStorageServiceProvider);
    final alerts = await storage.getDueDateAlerts();
    final days = await storage.getReminderLeadDays();
    state = NotificationSettings(
      dueDateAlerts: alerts,
      reminderLeadDays: days,
    );
  }

  Future<void> toggleDueDateAlerts() async {
    final newValue = !state.dueDateAlerts;
    state = state.copyWith(dueDateAlerts: newValue);
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveDueDateAlerts(newValue);
  }

  Future<void> setReminderLeadDays(int days) async {
    state = state.copyWith(reminderLeadDays: days);
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveReminderLeadDays(days);
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
