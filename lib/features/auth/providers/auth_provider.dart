import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_repository.dart';
import '../models/auth_request.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => AuthStatus.initial;

  Future<void> checkAuthStatus() async {
    state = AuthStatus.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      final hasToken = await repository.hasValidToken();
      state = hasToken ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (e) {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> login(LoginRequest request) async {
    state = AuthStatus.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(request);
      state = AuthStatus.authenticated;
    } catch (e) {
      state = AuthStatus.error;
      rethrow; // Let the UI catch and show the error message.
    }
  }

  Future<void> register(RegisterRequest request) async {
    state = AuthStatus.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(request);
      state = AuthStatus.authenticated;
    } catch (e) {
      state = AuthStatus.error;
      rethrow;
    }
  }

  Future<void> logout() async {
    state = AuthStatus.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = AuthStatus.unauthenticated;
    } catch (e) {
      state = AuthStatus.error;
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);
