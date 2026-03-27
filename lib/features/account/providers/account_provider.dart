import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// Provides the current user's profile loaded from secure storage.
class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return _loadFromStorage();
  }

  Future<User?> _loadFromStorage() async {
    final storage = ref.read(secureStorageServiceProvider);
    final id = await storage.getUserId();
    final email = await storage.getUserEmail();
    final name = await storage.getUserName();

    if (id == null || email == null || name == null) return null;

    return User(id: id, email: email, fullName: name);
  }

  /// Re-reads user info from secure storage (e.g. after login).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadFromStorage);
  }

  /// Clears the cached user state (e.g. on logout).
  void clear() {
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);
