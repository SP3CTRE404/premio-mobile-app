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

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final List<Widget> screens = [
      const DashboardScreen(),
      const DueScreen(),
      const AddSubscriptionScreen(),
      const HistoryScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      extendBody: true, // Allows body to scroll behind the floating nav bar
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
      body: screens[currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 89, 89, 89).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, Icons.home_outlined, Icons.home, 0, currentIndex, ref),
                _buildNavItem(context, Icons.notifications_none, Icons.notifications, 1, currentIndex, ref, hasBadge: true),
                _buildNavItem(context, Icons.add_circle_outline, Icons.add_circle, 2, currentIndex, ref),
                _buildNavItem(context, Icons.history, Icons.history, 3, currentIndex, ref),
                _buildNavItem(context, Icons.person_outline, Icons.person, 4, currentIndex, ref),
              ],
            ),
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
    final bgColor = isSelected ? Theme.of(context).primaryColor : Colors.transparent;

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
