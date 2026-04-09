import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import 'nav_item.dart';

class BottomNavBar extends ConsumerWidget {
  final bool isPill;

  const BottomNavBar({super.key, required this.isPill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userRole = ref.watch(userRoleProvider);
    final isSingle = userRole == UserRole.single;

    final radius = isPill ? BorderRadius.circular(42) : BorderRadius.zero;
    final baseColor =
        theme.bottomNavigationBarTheme.backgroundColor ?? Colors.black;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: isPill
          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)
          : EdgeInsets.zero,
      height: isPill ? 64 : 60 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isPill
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isPill ? baseColor : baseColor.withValues(alpha: 0.65),
              border: Border(
                top: BorderSide(
                  color: isPill
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.12),
                  width: isPill ? 0.0 : 0.8,
                ),
              ),
            ),
            child: Padding(
              padding: isPill
                  ? const EdgeInsets.all(12.0)
                  : EdgeInsets.fromLTRB(
                      16.0,
                      0,
                      16.0,
                      MediaQuery.of(context).padding.bottom,
                    ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NavItem(
                    outlinedIcon: isSingle
                        ? Icons.add_home_work_outlined
                        : Icons.home_outlined,
                    filledIcon: isSingle
                        ? Icons.add_home_work_rounded
                        : Icons.home_rounded,
                    label: 'Household',
                    index: 0,
                    isPill: isPill,
                  ),
                  NavItem(
                    outlinedIcon: Icons.receipt_long_outlined,
                    filledIcon: Icons.receipt_long_rounded,
                    label: 'Subscriptions',
                    index: 1,
                    isPill: isPill,
                  ),
                  NavItem(
                    outlinedIcon: Icons.grid_view_outlined,
                    filledIcon: Icons.grid_view_rounded,
                    label: 'Dashboard',
                    index: 2,
                    isProminent: true,
                    isPill: isPill,
                  ),
                  NavItem(
                    outlinedIcon: Icons.history_rounded,
                    filledIcon: Icons.history_rounded,
                    label: 'History',
                    index: 3,
                    isPill: isPill,
                  ),
                  NavItem(
                    outlinedIcon: Icons.person_outline_rounded,
                    filledIcon: Icons.person_rounded,
                    label: 'Account',
                    index: 4,
                    isPill: isPill,
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
