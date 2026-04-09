import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../account/providers/account_provider.dart';
import '../models/user_role.dart';

class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() {
    final user = ref.watch(userProvider).value;

    if (user == null || user.householdId == null) {
      return UserRole.single;
    }

    if (user.isHouseholdAdmin) {
      return UserRole.admin;
    }

    return UserRole.member;
  }
}

final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole>(
  UserRoleNotifier.new,
);
