import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/household_repository.dart';

class HouseholdNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  FutureOr<Map<String, dynamic>?> build() async {
    final repo = ref.read(householdRepositoryProvider);
    try {
      return await repo.getMyHousehold();
    } catch (e) {
      return null;
    }
  }

  Future<void> createHousehold(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      return await repo.createHousehold(name);
    });
  }

  Future<void> joinHousehold(String inviteCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      return await repo.joinHousehold(inviteCode);
    });
  }

  Future<void> leave() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.leaveHousehold();
      return null;
    });
  }

  Future<void> delete() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.deleteHousehold();
      return null;
    });
  }

  Future<void> transferAdmin(int newAdminId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.transferAdmin(newAdminId);
      return state.value; // Keep existing data or refresh
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      return await repo.getMyHousehold();
    });
  }

  Future<void> updateHouseholdName(String newName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.updateHouseholdName(newName);
      return await repo.getMyHousehold(); // refresh data
    });
  }

  Future<void> updateHouseholdImage(String base64Image) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.updateHouseholdImage(base64Image);
      return await repo.getMyHousehold(); // refresh data
    });
  }
}

final householdProvider = AsyncNotifierProvider<HouseholdNotifier, Map<String, dynamic>?>(
  HouseholdNotifier.new,
);
