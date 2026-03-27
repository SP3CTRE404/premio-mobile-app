import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import '../models/subscription_model.dart';
import '../models/subscription_request.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return SubscriptionRepository(dio: apiClient.dio, storage: storage);
});

class SubscriptionRepository {
  final Dio dio;
  final SecureStorageService storage;

  SubscriptionRepository({required this.dio, required this.storage});

  /// Helper to get the current user's ID from secure storage.
  Future<int> _getUserId() async {
    final id = await storage.getUserId();
    if (id == null) throw Exception('User ID not found. Please log in again.');
    return id;
  }

  /// GET /api/subscriptions/user/{userId}/monthly-total
  Future<double> getMonthlyTotal() async {
    final userId = await _getUserId();
    final response = await dio.get(ApiEndpoints.monthlyTotal(userId));
    return (response.data as num).toDouble();
  }

  /// GET /api/subscriptions/user/{userId}/due
  Future<List<Subscription>> getDueSubscriptions() async {
    final userId = await _getUserId();
    final response = await dio.get(ApiEndpoints.dueSubscriptions(userId));
    final list = response.data as List<dynamic>;
    return list
        .map((json) => Subscription.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/subscriptions/add
  Future<Subscription> addSubscription(SubscriptionRequest request) async {
    final response = await dio.post(
      ApiEndpoints.addSubscription,
      data: request.toJson(),
    );
    return Subscription.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/subscriptions/{id}/pay
  Future<Subscription> paySubscription(int id) async {
    final response = await dio.post(ApiEndpoints.paySubscription(id));
    return Subscription.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/subscriptions/{id}/toggle-autopay
  Future<Subscription> toggleAutoPay(int id) async {
    final response = await dio.post(ApiEndpoints.toggleAutoPay(id));
    return Subscription.fromJson(response.data as Map<String, dynamic>);
  }
}
