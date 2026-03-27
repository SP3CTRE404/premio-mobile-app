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
      const _VaultPlaceholder(), 
      const AccountScreen(),
    ];

    return Scaffold(
      extendBody: true,
      // ── AppBar: Restored with Title and Settings ──
      appBar: AppBar(
        title: const Text('SubTrack'),
        centerTitle: false,
        actions: [
          // ── Contextual Actions: Search & History (Vault Tab Only) ──
          if (currentIndex == 2) ...[
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
          ],
          // ── Global Settings Button ──
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.grid_view_rounded, 0, currentIndex),
              _buildNavItem(Icons.calendar_today_outlined, 1, currentIndex),
              const SizedBox(width: 40), // FAB Gap
              _buildNavItem(Icons.view_list_rounded, 2, currentIndex),
              _buildNavItem(Icons.person_outline_rounded, 3, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          size: 26,
        ),
      ),
    );
  }
}

class _VaultPlaceholder extends StatelessWidget {
  const _VaultPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // House button remains in the body of the Vault tab
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: const Icon(Icons.add_home_rounded),
              onPressed: () {},
            ),
          ),
        ),
        const Expanded(child: Center(child: Text('The Vault: All Subscriptions'))),
      ],
    );
  }
}