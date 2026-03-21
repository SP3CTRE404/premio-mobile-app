import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_repository.dart';
import '../models/auth_request.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial;

  Future<void> checkAuthStatus() async {
    state = AuthState.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      final hasToken = await repository.hasValidToken();
      state = hasToken ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login(LoginRequest request) async {
    state = AuthState.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(request);
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> register(RegisterRequest request) async {
    state = AuthState.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(request);
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.error;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
