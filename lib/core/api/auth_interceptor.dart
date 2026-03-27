import 'package:dio/dio.dart';
import '../secure_storage/secure_storage_service.dart';

/// Dio [Interceptor] that attaches `Authorization: Bearer <token>`
/// to every request whose path starts with `/api/`.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.startsWith('/api')) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid — downstream code should handle logout.
      // We could clear the token here, but it's better to let the
      // AuthNotifier react to the 401 so the UI navigates properly.
    }
    handler.next(err);
  }
}
