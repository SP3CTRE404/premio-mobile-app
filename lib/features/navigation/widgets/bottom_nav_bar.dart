import 'package:flutter/material.dart';

import 'nav_item.dart';

class BottomNavBar extends StatelessWidget {
  final bool isPill;

  const BottomNavBar({
    super.key,
    required this.isPill,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: isPill
          ? const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0)
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
            ? EdgeInsets.zero
            : EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: const Row(
          children: [
            NavItem(
              outlinedIcon: Icons.dashboard_outlined,
              filledIcon: Icons.dashboard,
              index: 0,
            ),
            NavItem(
              outlinedIcon: Icons.receipt_long_outlined,
              filledIcon: Icons.receipt_long,
              index: 1,
            ),
            NavItem(
              outlinedIcon: Icons.history,
              filledIcon: Icons.history,
              index: 2,
            ),
            NavItem(
              outlinedIcon: Icons.person_outline,
              filledIcon: Icons.person,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}
