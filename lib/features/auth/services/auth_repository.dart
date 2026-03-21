import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../models/auth_request.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: apiClient.dio, secureStorage: secureStorage);
});

class AuthRepository {
  final Dio apiClient;
  final FlutterSecureStorage secureStorage;

  AuthRepository({required this.apiClient, required this.secureStorage});

  Future<void> login(LoginRequest request) async {
    final response = await apiClient.post('/auth/login', data: request.toJson());
    final token = response.data['token'] as String;
    await secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<void> register(RegisterRequest request) async {
    await apiClient.post('/auth/register', data: request.toJson());
    // The prompt states /register returns a User object.
    // To issue a token, log them in immediately after.
    await login(LoginRequest(email: request.email, password: request.password));
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
  }

  Future<bool> hasValidToken() async {
    final token = await secureStorage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }
}
