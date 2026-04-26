import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'launching_item.dart';
import 'subscription_fab_small.dart';

class SubscriptionFabMenu extends StatefulWidget {
  const SubscriptionFabMenu({
    super.key,
    required this.onAddSubscriptionTap,
    required this.onSearchTap,
    this.onMenuToggle,
  });

  final VoidCallback onAddSubscriptionTap;
  final VoidCallback onSearchTap;
  final Function(bool)? onMenuToggle;

  @override
  State<SubscriptionFabMenu> createState() => SubscriptionFabMenuState();
}

class SubscriptionFabMenuState extends State<SubscriptionFabMenu>
    with TickerProviderStateMixin {
  bool _isMainMenuOpen = false;

  late final AnimationController _rowController;

  late final Animation<double> _curve1;
  late final Animation<double> _curve3;

  @override
  void initState() {
    super.initState();

    _rowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _curve3 = CurvedAnimation(
      parent: _rowController,
      curve: const Interval(0.00, 0.70, curve: Curves.easeOutCubic),
    );
    _curve1 = CurvedAnimation(
      parent: _rowController,
      curve: const Interval(0.20, 0.90, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _rowController.dispose();
    super.dispose();
  }

  void _toggleMainMenu() {
    setState(() => _isMainMenuOpen = !_isMainMenuOpen);
    widget.onMenuToggle?.call(_isMainMenuOpen);
    if (_isMainMenuOpen) {
      _rowController.forward();
    } else {
      _rowController.reverse();
    }
  }

  void closeAll() {
    setState(() {
      _isMainMenuOpen = false;
    });
    widget.onMenuToggle?.call(false);
    _rowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12.0;

    return SizedBox(
      width: 340,
      height: 400,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Main Controller FAB
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              heroTag: 'main_menu_fab',
              onPressed: _toggleMainMenu,
              backgroundColor: AppColors.cobaltBlue,
              shape: const CircleBorder(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween(begin: 0.875, end: 1.0).animate(anim),
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Icon(
                  _isMainMenuOpen ? Icons.close : Icons.menu_rounded,
                  size: 30,
                  key: ValueKey(_isMainMenuOpen),
                ),
              ),
            ),
          ),

          // Search Button 
          Positioned(
            bottom: 56 + spacing,
            right: 0,
            child: LaunchingItem(
              progress: _curve3,
              originDy: 1.5,
              child: SubscriptionFabSmall(
                icon: Icons.search_rounded,
                label: 'Search',
                onTap: () {
                  closeAll();
                  widget.onSearchTap();
                },
                showLabel: false,
              ),
            ),
          ),

          // Add Task Button
          Positioned(
            bottom: (56 * 2) + (spacing * 2),
            right: 0,
            child: LaunchingItem(
              progress: _curve1,
              originDy: 1.6,
              child: SubscriptionFabSmall(
                icon: Icons.add,
                label: 'Add Task',
                onTap: () {
                  closeAll();
                  widget.onAddSubscriptionTap();
                },
                showLabel: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}