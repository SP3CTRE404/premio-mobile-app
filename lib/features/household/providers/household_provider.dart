import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/household_repository.dart';
import '../../account/providers/account_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';



class HouseholdNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  FutureOr<Map<String, dynamic>?> build() async {
    // Watch auth status to ensure household data resets on login/logout
    ref.watch(authProvider);
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
      final result = await repo.createHousehold(name);
      
      // Refresh user profile to update householdId and roles
      await ref.read(userProvider.notifier).refresh();
      // Refresh subscriptions as they might now include shared ones
      await ref.read(subscriptionProvider.notifier).refresh();
      
      return result;
    });
  }


  Future<void> joinHousehold(String inviteCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      final result = await repo.joinHousehold(inviteCode);
      
      // Refresh user profile and subscriptions after joining
      await ref.read(userProvider.notifier).refresh();
      await ref.read(subscriptionProvider.notifier).refresh();
      
      return result;
    });
  }


  Future<void> leave() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.leaveHousehold();
      
      // Refresh profile and subs to remove shared context
      await ref.read(userProvider.notifier).refresh();
      await ref.read(subscriptionProvider.notifier).refresh();
      
      // Explicitly set state to null to trigger UI change instantly
      state = const AsyncData(null);
      return null;
    });
  }


  Future<void> delete() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.deleteHousehold();
      
      // Refresh profile and subs to remove shared context
      await ref.read(userProvider.notifier).refresh();
      await ref.read(subscriptionProvider.notifier).refresh();
      
      return null;
    });
  }


  Future<void> transferAdmin(int newAdminId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.transferAdmin(newAdminId);
      
      // Refresh user profile as admin status has changed
      await ref.read(userProvider.notifier).refresh();
      
      // Refresh household data and return it to update state
      return await repo.getMyHousehold();
    });
  }

  Future<void> handoverAndLeave(int newAdminId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      
      // 1. Transfer adminship
      await repo.transferAdmin(newAdminId);
      
      // 2. Immediately leave the household
      await repo.leaveHousehold();
      
      // 3. Refresh profile and subs once after everything is done
      await ref.read(userProvider.notifier).refresh();
      await ref.read(subscriptionProvider.notifier).refresh();
      
      // 4. Force state to null to trigger UI redirection
      state = const AsyncData(null);
      return null;
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

  Future<void> removeMember(int memberId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      await repo.removeMember(memberId);
      
      // Refresh household data and potentially user profile if roles changed
      final updated = await repo.getMyHousehold();
      await ref.read(userProvider.notifier).refresh();
      await ref.read(subscriptionProvider.notifier).refresh();
      return updated;
    });
  }
}

final householdProvider = AsyncNotifierProvider<HouseholdNotifier, Map<String, dynamic>?>(
  HouseholdNotifier.new,
);
