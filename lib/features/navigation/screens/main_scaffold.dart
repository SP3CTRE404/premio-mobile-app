import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../subscriptions/screens/due_screen.dart';
import '../../subscriptions/screens/add_subscription_screen.dart';
import '../../history/screens/history_screen.dart';
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
  /// true = pill (floating), false = docked (full-width at bottom)
  bool _isPill = true;

  // Track scroll position info
  bool _isAtBottom = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;

      // Check if we're at the bottom
      final atBottom = metrics.pixels >= metrics.maxScrollExtent - 1;

      if (atBottom && !_isAtBottom) {
        // Just reached the bottom → dock
        setState(() {
          _isAtBottom = true;
          _isPill = false;
        });
      } else if (!atBottom && _isAtBottom) {
        // Was at bottom, now scrolling up → pill
        setState(() {
          _isAtBottom = false;
          _isPill = true;
        });
      }

      // Also detect scroll direction when NOT at bottom
      if (!atBottom && notification.scrollDelta != null) {
        final scrollingUp = notification.scrollDelta! < 0;
        if (scrollingUp && !_isPill) {
          setState(() => _isPill = true);
        }
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
      const AddSubscriptionScreen(),
      const HistoryScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('SubTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'SubTrack Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: screens[currentIndex],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: _isPill
            ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0)
            : EdgeInsets.zero,
        height: _isPill ? 64 : 64 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: _isPill
              ? BorderRadius.circular(32)
              : BorderRadius.zero,
          boxShadow: _isPill
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 89, 89, 89)
                        .withValues(alpha: 0.1),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Icons.home_outlined, Icons.home, 0,
                  currentIndex, ref),
              _buildNavItem(context, Icons.notifications_none,
                  Icons.notifications, 1, currentIndex, ref,
                  hasBadge: true),
              _buildNavItem(context, Icons.edit_outlined,
                  Icons.edit, 2, currentIndex, ref),
              _buildNavItem(
                  context, Icons.history, Icons.history, 3, currentIndex, ref),
              _buildNavItem(context, Icons.person_outline, Icons.person, 4,
                  currentIndex, ref),
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
    final iconColor = isSelected
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    final bgColor =
        isSelected ? Theme.of(context).primaryColor : Colors.transparent;

    return GestureDetector(
      onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Badge(
          isLabelVisible: hasBadge,
          smallSize: 8,
          backgroundColor: Colors.redAccent,
          child: Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: iconColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}
