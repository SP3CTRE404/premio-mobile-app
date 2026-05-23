import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/features/subscriptions/screens/payment_history_screen.dart';
import 'package:subtrack/features/subscriptions/models/user_role.dart';
import 'package:subtrack/features/subscriptions/providers/user_role_provider.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../subscriptions/screens/subscription_detail_screen.dart';
import '../../subscriptions/screens/edit_subscriptions_screen.dart';
import '../../account/screens/account_screen.dart';
import '../../household/screens/household_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../tutorial/providers/tutorial_provider.dart';

import '../../account/providers/account_provider.dart';
import '../../household/screens/join_household_screen.dart';

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 2;

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
  int _previousIndex = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.metrics.axis == Axis.vertical) {
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
    final userRole = ref.watch(userRoleProvider);
    final isSingle = userRole == UserRole.single;

    // Fix #2: Only select the fields we actually need for the minor check
    final isMinorWithoutHousehold = ref.watch(userProvider.select((asyncUser) {
      final user = asyncUser.value;
      if (user == null) return false;
      return user.dateOfBirth != null &&
             user.age >= 0 &&
             user.age < 18 &&
             user.householdId == null;
    }));
    final isLoading = ref.watch(userProvider.select((u) => u.isLoading));
    final hasError = ref.watch(userProvider.select((u) => u.hasError));
    final errorMessage = ref.watch(userProvider.select((u) => u.error?.toString() ?? ''));

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (hasError) {
      return Scaffold(body: Center(child: Text('Error: $errorMessage')));
    }

    if (isMinorWithoutHousehold) {
      return const Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: 'Join a Household',
          isScrolled: false,
        ),
        body: JoinHouseholdScreen(),
      );
    }

    final List<Widget> screens = [
      const HouseholdScreen(),
      const SubscriptionDetailScreen(),
      const DashboardScreen(),
      const PaymentHistoryScreen(),
      const AccountScreen(),
    ];

    final List<String> titles = [
      isSingle ? 'Collaborate' : 'Household',
      'Ongoing Subscriptions',
      'SubTrack',
      'History',
      'Account',
    ];

    ref.listen(navigationIndexProvider, (previous, next) {
      if (previous != null) {
        _previousIndex = previous;
      }
      setState(() {
        _isScrolled = false;
        _isPill = true;
        _isAtBottom = false;
      });
    });

    ref.listen(tutorialProvider, (previous, next) {
      if (previous == null || previous.value == null) return;
      
      final prevStep = previous.value?.activeStep;
      final activeStep = next.value?.activeStep;
      if (prevStep == activeStep) return;

      if (activeStep == 'dashboard_hello') {
        ref.read(navigationIndexProvider.notifier).setIndex(2);
      } else if (activeStep == 'bottom_nav_household') {
        ref.read(navigationIndexProvider.notifier).setIndex(0);
      } else if (activeStep == 'bottom_nav_subscriptions') {
        ref.read(navigationIndexProvider.notifier).setIndex(1);
      } else if (activeStep == 'bottom_nav_history') {
        ref.read(navigationIndexProvider.notifier).setIndex(3);
      } else if (activeStep == 'bottom_nav_account') {
        ref.read(navigationIndexProvider.notifier).setIndex(4);
      }
    });

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        isScrolled: _isScrolled,
        title: titles[currentIndex],
        trailingAction: currentIndex == 1
            ? IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                tooltip: 'Manage Subscriptions',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditSubscriptionsScreen(),
                    ),
                  );
                },
              )
            : null,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final childIndex = (child.key as ValueKey<int>).value;
            final isForward = currentIndex >= _previousIndex;
            
            Offset beginOffset;
            if (childIndex == currentIndex) {
              beginOffset = Offset(isForward ? 1.0 : -1.0, 0.0);
            } else {
              beginOffset = Offset(isForward ? -1.0 : 1.0, 0.0);
            }

            return SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: SizedBox.expand(
            key: ValueKey<int>(currentIndex),
            child: screens[currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(isPill: _isPill),
    );
  }
}
