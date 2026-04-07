import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import 'nav_item.dart';

class BottomNavBar extends ConsumerWidget {
  final bool isPill;

  const BottomNavBar({
    super.key,
    required this.isPill,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final isSingle = userRole == UserRole.single;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: isPill
          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)
          : EdgeInsets.zero,
      height: isPill ? 64 : 60 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: isPill ? BorderRadius.circular(42) : BorderRadius.zero,
        boxShadow: isPill
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: isPill
            ? const EdgeInsets.all(12.0)
            : EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavItem(
              outlinedIcon: isSingle
                  ? Icons.add_home_work_outlined
                  : Icons.home_outlined,
              filledIcon: isSingle ? Icons.add_home_work_rounded : Icons.home_rounded,
              label: 'Household',
              index: 0,
            ),
            NavItem(
              outlinedIcon: Icons.receipt_long_outlined,
              filledIcon: Icons.receipt_long_rounded,
              label: 'Subs',
              index: 1,
            ),
            NavItem(
              outlinedIcon: Icons.grid_view_outlined,
              filledIcon: Icons.grid_view_rounded,
              label: 'Dashboard',
              index: 2,
              isProminent: true,
            ),
            NavItem(
              outlinedIcon: Icons.history_rounded,
              filledIcon: Icons.history_rounded,
              label: 'History',
              index: 3,
            ),
            NavItem(
              outlinedIcon: Icons.person_outline_rounded,
              filledIcon: Icons.person_rounded,
              label: 'Account',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }
}
