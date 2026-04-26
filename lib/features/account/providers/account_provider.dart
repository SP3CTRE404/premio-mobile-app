import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import '../../../core/api/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_model.dart';


class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Watch the auth status to trigger a re-build (and re-fetch) on login/logout
    ref.watch(authProvider);
    return _fetchUserFromApi();
  }


  /// Attempts to fetch the freshest profile from the backend.
  /// Falls back to secure storage if offline.
  Future<User?> _fetchUserFromApi() async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      // FIX: Changed from '/api/profile' to '/api/users/profile'
      final response = await dio.get('/api/users/profile');
      final user = User.fromJson(response.data);
      
      // Keep local storage in sync for quick loads
      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveUserName(user.fullName);
      if (user.phoneNumber != null) await storage.saveUserPhoneNumber(user.phoneNumber!);
      
      return user;
    } catch (e) {
      return _loadFromStorage();
    }
  }

  Future<User?> _loadFromStorage() async {
    final storage = ref.read(secureStorageServiceProvider);
    final id = await storage.getUserId();
    final email = await storage.getUserEmail();
    final name = await storage.getUserName();
    final phone = await storage.getUserPhoneNumber();

    if (id == null || email == null || name == null) return null;
    return User(id: id, email: email, fullName: name, phoneNumber: phone);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchUserFromApi);
  }

  void clear() {
    state = const AsyncData(null);
  }

  /// Sends updated profile data (including base64 image) to backend.
  Future<void> updateProfile({
    required String fullName, 
    String? phoneNumber,
    String? profilePicture, // NEW: Accept image string
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(apiClientProvider).dio;
      
      // FIX: Changed from '/api/profile' to '/api/users/profile'
      final response = await dio.put('/api/users/profile', data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'profilePicture': profilePicture,
      });

      final updatedUser = User.fromJson(response.data);
      
      // Update local storage names
      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveUserName(updatedUser.fullName);
      if (updatedUser.phoneNumber != null) {
        await storage.saveUserPhoneNumber(updatedUser.phoneNumber!);
      }

      return updatedUser;
    });
  }

  /// Resets the user's password (called after biometric verification).
  Future<void> resetPassword(String newPassword) async {
    final dio = ref.read(apiClientProvider).dio;
    await dio.put('/api/users/reset-password', data: {
      'newPassword': newPassword,
    });
  }

  /// Permanently deletes the user account from the system.
  Future<void> deleteAccount() async {
    final dio = ref.read(apiClientProvider).dio;
    await dio.delete('/api/users/profile');
    
    // Clear local user data
    clear();
    // Trigger logout to clean up token and redirects
    await ref.read(authProvider.notifier).logout();
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);