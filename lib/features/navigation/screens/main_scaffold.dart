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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
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

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('SubTrack'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: screens[currentIndex],
      ),
      
      // Global FAB is null; handled contextually in SubscriptionDetailScreen
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
            // Removed SpaceEvenly so Expanded widgets can control distribution
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
        onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically inside the Expanded block
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                // Samsung S24 Material 3 style pill
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