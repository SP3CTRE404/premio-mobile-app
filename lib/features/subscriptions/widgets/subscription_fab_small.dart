import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SubscriptionFabSmall extends StatelessWidget {
  const SubscriptionFabSmall({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isVertical = true,
    this.showLabel = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isVertical;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    // Define the interactive button part with an expanded hit area (60x60)
    final buttonWithHitArea = Stack(
      alignment: Alignment.center,
      children: [
        // Invisible hit area extension for better touch precision
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(width: 60, height: 60),
        ),
        // Visual Small FAB
        FloatingActionButton.small(
          heroTag: 'small_fab_$label',
          onPressed: onTap,
          backgroundColor: AppColors.cobaltBlue.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );

    // Build the layout ensuring labels are outside the interactive stack
    if (isVertical) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          buttonWithHitArea,
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buttonWithHitArea,
          const SizedBox(height: 4),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    }
  }
}