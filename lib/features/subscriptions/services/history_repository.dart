import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/history_model.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HistoryRepository(dio: apiClient.dio);
});

/// Repository for subscription payment history.
///
/// The specific endpoint paths will be added once the Spring Boot
/// backend exposes history routes. The plumbing is ready.
class HistoryRepository {
  final Dio dio;

  HistoryRepository({required this.dio});

  /// Fetches payment history for a given subscription.
  /// Endpoint TBD — placeholder path used.
  Future<List<SubscriptionHistory>> getHistory(int subscriptionId) async {
    final response = await dio.get('/api/subscriptions/$subscriptionId/history');
    final list = response.data as List<dynamic>;
    return list
        .map((json) =>
            SubscriptionHistory.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
