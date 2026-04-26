import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';

class AppLockNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final storage = ref.read(secureStorageServiceProvider);
    return await storage.getAppLockEnabled();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveAppLockEnabled(enabled);
      return enabled;
    });
  }
}

final appLockProvider = AsyncNotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);
