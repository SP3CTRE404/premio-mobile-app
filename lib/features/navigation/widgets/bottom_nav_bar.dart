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

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Exact height of the widget container (no bottomPadding for pill)
    final double widgetHeight = isPill ? 104.0 : 60.0 + bottomPadding;

    // Total height of the blurred background region
    final double blurHeight = isPill ? 84.0 : 60.0 + bottomPadding;

    // Start Y coordinate of the blurred background region
    final double blurStartY = isPill ? 20.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: widgetHeight,
      width: double.infinity,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. The progressive blur regions (5 adjacent vertical strips of increasing blur)
          for (int i = 0; i < 5; i++)
            AnimatedPositioned(
              key: ValueKey('blur_segment_$i'),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              top: blurStartY + (i * (blurHeight / 5.0)),
              height: blurHeight / 5.0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: (i + 1) * 1.8,
                    sigmaY: (i + 1) * 1.8,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

          // 2. The progressive gradient color overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            top: blurStartY,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.0),
                      theme.colorScheme.surface.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. The main navigation bar container
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              margin: isPill
                  ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)
                  : EdgeInsets.zero,
              height: isPill ? 64 : 60 + bottomPadding,
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
                  filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPill ? baseColor.withValues(alpha: 0.75) : baseColor.withValues(alpha: 0.65),
                      borderRadius: radius,
                      border: Border.all(
                        color: isPill
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.12),
                        width: isPill ? 1.0 : 0.8,
                      ),
                    ),
                    child: Padding(
                      padding: isPill
                          ? const EdgeInsets.all(12.0)
                          : EdgeInsets.fromLTRB(
                              16.0,
                              0,
                              16.0,
                              bottomPadding,
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
            ),
          ),
        ],
      ),
    );
  }
}
