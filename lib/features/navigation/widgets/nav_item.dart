import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/main_scaffold.dart';

class NavItem extends ConsumerWidget {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final int index;
  final bool hasBadge;

  const NavItem({
    super.key,
    required this.outlinedIcon,
    required this.filledIcon,
    required this.index,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Badge(
              isLabelVisible: hasBadge,
              smallSize: 8,
              backgroundColor: Colors.redAccent,
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected
                    ? theme.primaryColor
                    : colorScheme.onSurface.withOpacity(0.5),
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
