import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../subscriptions/screens/due_screen.dart';
import '../../subscriptions/screens/subscription_detail_screen.dart'; 
import '../../account/screens/account_screen.dart';
import '../../settings/screens/settings_screen.dart';

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final navigationIndexProvider =
    NotifierProvider<NavigationIndexNotifier, int>(NavigationIndexNotifier.new);

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with SingleTickerProviderStateMixin {
  bool _isPill = true;
  bool _isAtBottom = false;
  
  // ── NEW: Track if the user has scrolled down from the top ──
  bool _isScrolled = false; 

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      
      // ── Toggle header glassmorphism based on scroll offset ──
      final scrolled = metrics.pixels > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }

      // Track bottom nav behavior
      final atBottom = metrics.pixels >= metrics.maxScrollExtent - 1;

      if (atBottom && !_isAtBottom) {
        setState(() {
          _isAtBottom = true;
          _isPill = false;
        });
      } else if (!atBottom && _isAtBottom) {
        setState(() {
          _isAtBottom = false;
          _isPill = true;
        });
      }

      if (!atBottom && notification.scrollDelta != null) {
        final scrollingUp = notification.scrollDelta! < 0;
        if (scrollingUp && !_isPill) setState(() => _isPill = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final List<Widget> screens = [
      const DashboardScreen(),
      const DueScreen(),
      const SubscriptionDetailScreen(),
      const AccountScreen(),
    ];

    // Calculate dynamic colors based on the scroll state
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true, 
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        
        // ── Dynamic Frosted Glass Pill for the Title ──
        title: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), // Smooth fade transition
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Fades in the surface color when scrolled
                color: surfaceColor.withValues(alpha: _isScrolled ? 0.75 : 0.0),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  // Fades in the border when scrolled
                  color: onSurfaceColor.withValues(alpha: _isScrolled ? 0.1 : 0.0),
                  width: 1,
                ),
              ),
              child: const Text('SubTrack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
        ),
        
        actions: [
          // ── Dynamic Frosted Glass Pill for the Settings Button ──
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: _isScrolled ? 0.75 : 0.0),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: onSurfaceColor.withValues(alpha: _isScrolled ? 0.1 : 0.0),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: screens[currentIndex],
      ),
      
      floatingActionButton: null,

      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: _isPill
            ? const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0)
            : EdgeInsets.zero,
        height: _isPill ? 64 : 64 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: _isPill ? BorderRadius.circular(32) : BorderRadius.zero,
          boxShadow: _isPill
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: _isPill
              ? EdgeInsets.zero
              : EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            children: [
              _buildNavItem(context, Icons.home_outlined, Icons.home, 0, currentIndex, ref),
              _buildNavItem(context, Icons.notifications_none, Icons.notifications, 1, currentIndex, ref),
              _buildNavItem(context, Icons.view_list_outlined, Icons.view_list_rounded, 2, currentIndex, ref),
              _buildNavItem(context, Icons.person_outline, Icons.person, 3, currentIndex, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    int index,
    int currentIndex,
    WidgetRef ref, {
    bool hasBadge = false,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
          // Reset UI states when switching tabs to ensure the header doesn't stay frosted if the new tab is at the top
          setState(() {
            _isScrolled = false;
            _isPill = true;
            _isAtBottom = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.primaryColor.withValues(alpha: 0.2) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Badge(
                isLabelVisible: hasBadge,
                smallSize: 8,
                backgroundColor: Colors.redAccent,
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: isSelected 
                      ? theme.primaryColor 
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}