import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/main_scaffold.dart';

class NavItem extends ConsumerWidget {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
  final int index;
  final bool hasBadge;
  final bool isProminent;

  const NavItem({
    super.key,
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
    required this.index,
    this.hasBadge = false,
    this.isProminent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    // If prominent and selected, use primary color. Otherwise, use a subtle dark grey pill for selection.
    final backgroundColor = isSelected
        ? (isProminent ? const Color(0xFF003366) : theme.colorScheme.onSurface.withValues(alpha: 0.15))
        : (isProminent ? theme.primaryColor.withValues(alpha: 0.05) : const Color.fromARGB(0, 0, 0, 0));

    final contentColor = isSelected
        ? (isProminent ? Colors.white : theme.colorScheme.onSurface)
        : theme.bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;

    return GestureDetector(
      onTap: () {
        ref.read(navigationIndexProvider.notifier).setIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12,
            vertical: isProminent && isSelected ? 7 : 9,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isProminent && isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00BFFF).withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: hasBadge,
                smallSize: 8,
                backgroundColor: Colors.redAccent,
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: contentColor,
                  size: isProminent && isSelected ? 26 : 22,
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: isSelected ? null : 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: isSelected ? 8.0 : 0),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: contentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
