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
    final body = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isVertical && showLabel) ...[
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
        FloatingActionButton.small(
          heroTag: 'small_fab_$label',
          onPressed: onTap,
          backgroundColor: AppColors.cobaltBlue.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );

    if (!showLabel) return body;

    return isVertical
        ? body
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              body,
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
