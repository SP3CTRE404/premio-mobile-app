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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withValues(alpha: 0.2)
                  : const Color.fromARGB(0, 0, 0, 0),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Badge(
              isLabelVisible: hasBadge,
              smallSize: 8,
              backgroundColor: Colors.redAccent,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected
                      ? theme.primaryColor
                      : theme.bottomNavigationBarTheme.unselectedItemColor,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
