import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../secure_storage/secure_storage_service.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storage: storage, ref: ref);
});

class ApiClient {
  late final Dio dio;
  late final AuthInterceptor authInterceptor;
  final SecureStorageService storage;
  final Ref ref;

  ApiClient({required this.storage, required this.ref}) {
    authInterceptor = AuthInterceptor(storage, ref);

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          // Fix #1: Request gzip-compressed responses from the backend.
          // Spring Boot will auto-compress if server.compression.enabled=true.
          'Accept-Encoding': 'gzip, deflate',
        },
      ),
    );

    dio.interceptors.add(authInterceptor);
  }

  /// Warms up the in-memory token cache from secure storage.
  /// Should be called once during app initialization.
  Future<void> warmUpToken() => authInterceptor.warmUpToken();
}
