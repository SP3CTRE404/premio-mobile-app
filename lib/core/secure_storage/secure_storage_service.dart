import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Typed wrapper around [FlutterSecureStorage].
/// Keeps raw key strings private so the rest of the app
/// only calls semantic methods like [saveToken] / [getUserId].
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // ── Keys ──
  static const _keyJwt = 'jwt_token';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_full_name';
  static const _keyUserPhone = 'user_phone_number';

  // Settings keys
  static const _keyCurrency = 'currency_symbol';
  static const _keyThemeMode = 'theme_mode';
  static const _keyDueDateAlerts = 'due_date_alerts';
  static const _keyReminderLeadDays = 'reminder_lead_days';
  static const _keyAppLockEnabled = 'app_lock_enabled';
  static const _keyFallbackPin = 'fallback_pin';
  static const _keyOnboardingCompleted = 'onboarding_completed';

  // ── Token ──
  Future<void> saveToken(String token) =>
      _storage.write(key: _keyJwt, value: token);

  Future<String?> getToken() => _storage.read(key: _keyJwt);

  Future<void> deleteToken() => _storage.delete(key: _keyJwt);

  // ── User profile ──
  Future<void> saveUserId(int id) =>
      _storage.write(key: _keyUserId, value: id.toString());

  Future<int?> getUserId() async {
    final raw = await _storage.read(key: _keyUserId);
    return raw != null ? int.tryParse(raw) : null;
  }

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _keyUserEmail, value: email);

  Future<String?> getUserEmail() => _storage.read(key: _keyUserEmail);

  Future<void> saveUserName(String name) =>
      _storage.write(key: _keyUserName, value: name);

  Future<String?> getUserName() => _storage.read(key: _keyUserName);

  Future<void> saveUserPhoneNumber(String? phone) =>
      _storage.write(key: _keyUserPhone, value: phone);

  Future<String?> getUserPhoneNumber() => _storage.read(key: _keyUserPhone);

  // ── Settings: Currency ──
  Future<void> saveCurrency(String symbol) =>
      _storage.write(key: _keyCurrency, value: symbol);

  Future<String?> getCurrency() => _storage.read(key: _keyCurrency);

  // ── Settings: Theme Mode ──
  Future<void> saveThemeMode(String mode) =>
      _storage.write(key: _keyThemeMode, value: mode);

  Future<String?> getThemeMode() => _storage.read(key: _keyThemeMode);

  // ── Settings: Notification Preferences ──
  Future<void> saveDueDateAlerts(bool enabled) =>
      _storage.write(key: _keyDueDateAlerts, value: enabled.toString());

  Future<bool> getDueDateAlerts() async {
    final raw = await _storage.read(key: _keyDueDateAlerts);
    return raw == 'true';
  }

  Future<void> saveReminderLeadDays(int days) =>
      _storage.write(key: _keyReminderLeadDays, value: days.toString());

  Future<int> getReminderLeadDays() async {
    final raw = await _storage.read(key: _keyReminderLeadDays);
    return raw != null ? (int.tryParse(raw) ?? 1) : 1;
  }

  // ── Settings: App Lock ──
  Future<void> saveAppLockEnabled(bool enabled) =>
      _storage.write(key: _keyAppLockEnabled, value: enabled.toString());

  Future<bool> getAppLockEnabled() async {
    final raw = await _storage.read(key: _keyAppLockEnabled);
    return raw == 'true';
  }

  // ── Fallback PIN ──
  Future<void> saveFallbackPin(String pin) =>
      _storage.write(key: _keyFallbackPin, value: pin);

  Future<String?> getFallbackPin() => _storage.read(key: _keyFallbackPin);

  Future<bool> hasFallbackPin() async {
    final pin = await getFallbackPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<void> deleteFallbackPin() => _storage.delete(key: _keyFallbackPin);

  // ── Onboarding Tutorials ──
  Future<void> saveTutorialCompleted(String tutorialId, bool completed) =>
      _storage.write(key: 'tutorial_completed_$tutorialId', value: completed.toString());

  Future<bool> isTutorialCompleted(String tutorialId) async {
    final raw = await _storage.read(key: 'tutorial_completed_$tutorialId');
    return raw == 'true';
  }

  Future<void> deleteTutorialCompleted(String tutorialId) =>
      _storage.delete(key: 'tutorial_completed_$tutorialId');

  // ── Onboarding Screen ──
  Future<void> saveOnboardingCompleted(bool completed) =>
      _storage.write(key: _keyOnboardingCompleted, value: completed.toString());

  Future<bool> isOnboardingCompleted() async {
    final raw = await _storage.read(key: _keyOnboardingCompleted);
    return raw == 'true';
  }

  // ── Clear all ──
  Future<void> clearAll() => _storage.deleteAll();
}
