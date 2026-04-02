import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/user_role.dart';
import './launching_item.dart';
import './subscription_fab_small.dart';

class SubscriptionFabMenu extends StatefulWidget {
  const SubscriptionFabMenu({
    super.key,
    required this.onHistoryTap,
    required this.onAddSubscriptionTap,
    required this.onAddHouseholdTap,
    this.onMenuToggle,
    this.userRole = UserRole.single,
  });

  final VoidCallback onHistoryTap;
  final VoidCallback onAddSubscriptionTap;
  final VoidCallback onAddHouseholdTap;
  final Function(bool)? onMenuToggle;
  final UserRole userRole;

  @override
  State<SubscriptionFabMenu> createState() => SubscriptionFabMenuState();
}

class SubscriptionFabMenuState extends State<SubscriptionFabMenu>
    with TickerProviderStateMixin {
  bool _isMainMenuOpen = false;
  bool _isAddMenuOpen = false;

  late final AnimationController _rowController;
  late final AnimationController _addMenuController;

  late final Animation<double> _curve1; // History
  late final Animation<double> _curve2; // Add "+"
  late final Animation<double> _curve3; // Search

  late final Animation<double> _subCurve1; // Add Subscription
  late final Animation<double> _subCurve2; // Add/Join Household

  @override
  void initState() {
    super.initState();

    _rowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _addMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _curve3 = CurvedAnimation(
      parent: _rowController,
      curve: const Interval(0.00, 0.65, curve: Curves.easeOutCubic),
    );
    _curve2 = CurvedAnimation(
      parent: _rowController,
      curve: const Interval(0.12, 0.76, curve: Curves.easeOutCubic),
    );
    _curve1 = CurvedAnimation(
      parent: _rowController,
      curve: const Interval(0.24, 0.88, curve: Curves.easeOutCubic),
    );

    _subCurve1 = CurvedAnimation(
      parent: _addMenuController,
      curve: const Interval(0.00, 0.65, curve: Curves.easeOutCubic),
    );
    _subCurve2 = CurvedAnimation(
      parent: _addMenuController,
      curve: const Interval(0.18, 0.82, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _rowController.dispose();
    _addMenuController.dispose();
    super.dispose();
  }

  void _toggleMainMenu() {
    setState(() => _isMainMenuOpen = !_isMainMenuOpen);
    widget.onMenuToggle?.call(_isMainMenuOpen);
    if (_isMainMenuOpen) {
      _rowController.forward();
    } else {
      _rowController.reverse();
      _isAddMenuOpen = false;
      _addMenuController.reverse();
    }
  }

  void _toggleAddMenu() {
    setState(() => _isAddMenuOpen = !_isAddMenuOpen);
    if (_isAddMenuOpen) {
      _addMenuController.forward();
    } else {
      _addMenuController.reverse();
    }
  }

  void closeAll() {
    setState(() {
      _isMainMenuOpen = false;
      _isAddMenuOpen = false;
    });
    widget.onMenuToggle?.call(false);
    _rowController.reverse();
    _addMenuController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12.0;

    return SizedBox(
      width: 340,
      height: 400, // Large enough to contain the unfolded menu
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
                onTap: () {},
                showLabel: false,
              ),
            ),
          ),

          // Add "+" with horizontal sub-menu
          Positioned(
            bottom: (56 + spacing) * 2,
            right: 0,
            child: LaunchingItem(
              progress: _curve2,
              originDy: 1.6, // Adjusted for taller Row height (from 56 to ~88)
              child: SizedBox(
                width: 340,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.userRole == UserRole.single) ...[
                          LaunchingItem(
                            progress: _subCurve2,
                            originDx: 1.7,
                            child: SubscriptionFabSmall(
                              icon: Icons.add_home_rounded,
                              label: 'Add/Join Household',
                              isVertical: false,
                              onTap: () {
                                closeAll();
                                widget.onAddHouseholdTap();
                              },
                            ),
                          ),
                          const SizedBox(width: spacing),
                        ],
                        LaunchingItem(
                          progress: _subCurve1,
                          originDx: 0.7,
                          child: SubscriptionFabSmall(
                            icon: Icons.post_add_rounded,
                            label: 'Add Subscription',
                            isVertical: false,
                            onTap: () {
                              closeAll();
                              widget.onAddSubscriptionTap();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    // Sub-menu trigger with expanded hit area
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.userRole == UserRole.single) {
                              _toggleAddMenu();
                            } else {
                              closeAll();
                              widget.onAddSubscriptionTap();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(width: 56, height: 56),
                        ),
                        FloatingActionButton.small(
                          heroTag: 'horizontal_add_fab',
                          onPressed: () {
                            if (widget.userRole == UserRole.single) {
                              _toggleAddMenu();
                            } else {
                              closeAll();
                              widget.onAddSubscriptionTap();
                            }
                          },
                          backgroundColor: AppColors.cobaltBlue,
                          shape: const CircleBorder(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) => RotationTransition(
                              turns: Tween(begin: 0.875, end: 1.0).animate(anim),
                              child: ScaleTransition(scale: anim, child: child),
                            ),
                            child: Icon(
                              _isAddMenuOpen ? Icons.close : Icons.add,
                              color: Colors.white,
                              key: ValueKey(_isAddMenuOpen),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // History Button
          Positioned(
            bottom: (56 + spacing) * 3,
            right: 0,
            child: LaunchingItem(
              progress: _curve1,
              originDy: 4.1,
              child: SubscriptionFabSmall(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () {
                  closeAll();
                  widget.onHistoryTap();
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