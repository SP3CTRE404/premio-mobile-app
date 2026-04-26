import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Local Category Definitions ──
class CategoryDef {
  final String label;
  final IconData icon;
  const CategoryDef(this.label, this.icon);
}

const _defaultCategories = [
  CategoryDef('All', Icons.grid_view_rounded),
  CategoryDef('Entertainment', Icons.movie_outlined),
  CategoryDef('Productivity', Icons.engineering_outlined),
  CategoryDef('Cloud', Icons.cloud_outlined),
  CategoryDef('Finance', Icons.account_balance_outlined),
  CategoryDef('Utilities', Icons.power_outlined),
];

/// Horizontally scrollable category filter chips.
class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final List<CategoryDef> categories; // Optional parameter if we make it dynamic later

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.categories = _defaultCategories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = selectedCategory == cat.label;

          return GestureDetector(
            onTap: () => onCategorySelected(cat.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cobaltBlue.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cobaltBlue
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.cobaltBlue
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.cobaltBlue
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

