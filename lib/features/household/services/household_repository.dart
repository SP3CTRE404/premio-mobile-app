import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HouseholdRepository(dio: apiClient.dio);
});

class HouseholdRepository {
  final Dio dio;
  HouseholdRepository({required this.dio});

  Future<Map<String, dynamic>> createHousehold(String name) async {
    final response = await dio.post('/api/households', data: {'name': name});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinHousehold(String inviteCode) async {
    final response = await dio.post('/api/households/join', data: {'inviteCode': inviteCode});
    return response.data as Map<String, dynamic>;
  }

  Future<void> leaveHousehold() async {
    await dio.post('/api/households/leave');
  }

  Future<void> deleteHousehold() async {
    await dio.delete('/api/households');
  }

  Future<void> transferAdmin(int newAdminId) async {
    await dio.post('/api/households/transfer-admin', data: {'newAdminId': newAdminId});
  }
  
  Future<Map<String, dynamic>> getMyHousehold() async {
    final response = await dio.get('/api/households/my');
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateHouseholdName(String name) async {
    await dio.put('/api/households/name', data: {'name': name});
  }

  Future<void> updateHouseholdImage(String base64Image) async {
    await dio.put('/api/households/image', data: {'imageUrl': base64Image});
  }

  Future<void> removeMember(int memberId) async {
    await dio.delete('/api/households/members/$memberId');
  }
}
