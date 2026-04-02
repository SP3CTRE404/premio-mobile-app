import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';

/// Managed state for the current app preview role.
/// In a real app, this would be derived from the user's account data.
class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() {
    return UserRole.single;
  }

  void setRole(UserRole role) {
    state = role;
  }
}

final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole>(
  UserRoleNotifier.new,
);
