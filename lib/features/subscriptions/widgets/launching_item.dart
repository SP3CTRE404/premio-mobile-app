import 'package:flutter/material.dart';

/// Animates a widget launching from the main FAB origin to its resting place.
///
/// For horizontal row items: set [originDx] (positive = starts to the right,
/// toward the main FAB). Omit [originDy].
///
/// For vertical sub-menu items: set [originDy] (positive = starts below,
/// toward the "+" FAB). Omit [originDx].
class LaunchingItem extends StatelessWidget {
  const LaunchingItem({
    super.key,
    required this.progress,
    required this.child,
    this.originDx = 0.0,
    this.originDy = 0.0,
  });

  final Animation<double> progress;
  final Widget child;

  /// How many of this widget's own widths to the RIGHT it starts (horizontal launch).
  final double originDx;

  /// How many of this widget's own heights BELOW it starts (vertical launch).
  final double originDy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        return FractionalTranslation(
          // At t=0 the widget sits on top of the launch origin; at t=1 it's home.
          translation: Offset(
            originDx * (1.0 - t),
            originDy * (1.0 - t),
          ),
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: t.clamp(0.0, 1.0),
              // Scale from the side facing the main FAB so it truly looks like
              // it's growing out of that point.
              alignment: originDy != 0 ? Alignment.bottomCenter : Alignment.centerRight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
