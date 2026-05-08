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
    final data = response.data;
    
    if (data is List) {
      return data.map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is Map<String, dynamic>) {
      // If it's a paginated response (Spring Page object)
      final content = data['content'] as List? ?? [];
      return content.map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// GET paginated history for a user.
  /// Returns a [PaginatedHistory] containing the page of items and metadata.
  Future<PaginatedHistory> getUserHistory({int? userId, int page = 0, int size = 20}) async {
    final effectiveId = userId ?? await _getUserId();
    final response = await dio.get(
      ApiEndpoints.userHistory(effectiveId),
      queryParameters: {'page': page, 'size': size},
    );

    final data = response.data;

    // Support both paginated response (Map) and legacy flat list (List)
    if (data is Map<String, dynamic>) {
      final content = (data['content'] as List<dynamic>)
          .map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedHistory(
        items: content,
        page: data['page'] as int? ?? page,
        totalElements: data['totalElements'] as int? ?? content.length,
        hasMore: data['hasMore'] as bool? ?? false,
      );
    } else {
      // Legacy fallback: plain list response
      final list = data as List<dynamic>;
      final items = list.map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>)).toList();
      return PaginatedHistory(
        items: items,
        page: 0,
        totalElements: items.length,
        hasMore: false,
      );
    }
  }
}

/// Holds a page of history items along with pagination metadata.
class PaginatedHistory {
  final List<SubscriptionHistory> items;
  final int page;
  final int totalElements;
  final bool hasMore;

  const PaginatedHistory({
    required this.items,
    required this.page,
    required this.totalElements,
    required this.hasMore,
  });
}
