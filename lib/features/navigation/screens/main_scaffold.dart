import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../subscriptions/screens/due_screen.dart';
import '../../subscriptions/screens/subscription_detail_screen.dart';
import '../../account/screens/account_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  bool _isPill = true;
  bool _isAtBottom = false;
  bool _isScrolled = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      final scrolled = metrics.pixels > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }

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

    final List<String> titles = [
      'SubTrack',
      'Due Subscriptions',
      'All Subscriptions',
      'Account',
    ];

    ref.listen(navigationIndexProvider, (_, _) {
      setState(() {
        _isScrolled = false;
        _isPill = true;
        _isAtBottom = false;
      });
    });

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        isScrolled: _isScrolled,
        title: titles[currentIndex],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: screens[currentIndex],
      ),
      bottomNavigationBar: BottomNavBar(isPill: _isPill),
    );
  }
}
