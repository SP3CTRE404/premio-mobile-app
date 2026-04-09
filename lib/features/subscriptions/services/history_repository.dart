import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import '../models/history_model.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return HistoryRepository(dio: apiClient.dio, storage: storage);
});

class HistoryRepository {
  final Dio dio;
  final SecureStorageService storage;

  HistoryRepository({required this.dio, required this.storage});

  Future<int> _getUserId() async {
    final id = await storage.getUserId();
    if (id == null) throw Exception('User not logged in');
    return id;
  }

  // Gets history for a single subscription
  Future<List<SubscriptionHistory>> getHistory(int subscriptionId) async {
    final response = await dio.get(ApiEndpoints.subscriptionHistory(subscriptionId));
    final list = response.data as List<dynamic>;
    return list.map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET global history for the user (Dashboard/History Tab)
  Future<List<SubscriptionHistory>> getUserHistory() async {
    final userId = await _getUserId();
    final response = await dio.get(ApiEndpoints.userHistory(userId));
    final list = response.data as List<dynamic>;
    return list.map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>)).toList();
  }
}

