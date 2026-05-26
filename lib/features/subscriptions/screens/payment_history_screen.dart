import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/subscription_model.dart';
import '../providers/history_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/user_role_provider.dart';
import '../models/user_role.dart';
import '../../account/providers/account_provider.dart';
import '../utils/subscription_ui_helper.dart';
import '../widgets/history/payment_history_list_view.dart';
import '../widgets/history/subscription_history_bubble.dart';
import '../../tutorial/widgets/tutorial_anchor.dart';
import '../../tutorial/widgets/tutorial_bubble.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  final int? memberId;
  final String? memberName;

  const PaymentHistoryScreen({
    super.key,
    this.memberId,
    this.memberName,
  });

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(nativeCurrencyProvider);

    // If viewing a specific member's history (Admin View - Pushed Screen)
    if (widget.memberId != null) {
      final historyAsync = ref.watch(memberHistoryProvider(widget.memberId!));
      
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.memberName}\'s History'),
          centerTitle: true,
        ),
        body: historyAsync.when(
          data: (historyList) {
            final sortedList = List.of(historyList)
              ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
            return PaymentHistoryListView(
              historyItems: sortedList,
              currencySymbol: currencySymbol,
              tabPrefix: 'history_member_${widget.memberId}',
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading history: $err')),
        ),
      );
    }

    // Personal View (Tab View)
    final activeAsync = ref.watch(subscriptionProvider);
    final expiredAsync = ref.watch(expiredSubscriptionsProvider);
    final userAsync = ref.watch(userProvider);
    final userRole = ref.watch(userRoleProvider);
    
    // Account for the MainScaffold's transparent AppBar
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 40;

    return _buildSubscriptionList(
      activeAsync: activeAsync,
      expiredAsync: expiredAsync,
      currencySymbol: currencySymbol,
      topPadding: topPadding,
      userRole: userRole,
      currentUserId: userAsync.value?.id,
    );
  }

  Widget _buildSubscriptionList({
    required AsyncValue<List<Subscription>> activeAsync,
    required AsyncValue<List<Subscription>> expiredAsync,
    required String currencySymbol,
    required double topPadding,
    required UserRole userRole,
    required int? currentUserId,
  }) {
    if (activeAsync.isLoading || expiredAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeItems = activeAsync.value ?? [];
    final expiredItems = expiredAsync.value ?? [];
    
    final viewableActive = userRole == UserRole.admin
        ? activeItems
        : activeItems.where((s) => s.ownerId == currentUserId).toList();

    final allItems = [...viewableActive, ...expiredItems];

    if (allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const TutorialAnchor(
            tutorialId: 'bottom_nav_history',
            title: 'Payment History',
            description: 'This is where your payment logs are tracked. Tap on any subscription to view transaction details.',
            arrowDirection: ArrowDirection.up,
            child: Text('No subscriptions found.'),
          ),
        ),
      );
    }

    // Sort by name
    allItems.sort((a, b) => a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase()));

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 120),
      itemCount: allItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = allItems[index];
        final item = _SubscriptionHistoryListItem(
          subscription: sub,
          currencySymbol: currencySymbol,
          onTap: () => _showHistoryBubble(sub, currencySymbol),
        );
        if (index == 0) {
          return TutorialAnchor(
            tutorialId: 'bottom_nav_history',
            title: 'Payment History',
            description: 'This is your payment logs list. Tap any subscription in this history list to inspect its details and billing logs.',
            arrowDirection: ArrowDirection.up,
            child: item,
          );
        }
        return item;
      },
    );
  }

  void _showHistoryBubble(Subscription sub, String currencySymbol) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.2),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SubscriptionHistoryBubble(
            subscription: sub,
            currencySymbol: currencySymbol,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastOutSlowIn,
          );

          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final t = curved.value;
              final blur = 12.0 * t;
              final tilt = -0.04 * t;

              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: FadeTransition(
                  opacity: curved,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..multiply(Matrix4.diagonal3Values(
                        0.9 + (0.1 * t), 
                        0.9 + (0.1 * t), 
                        1.0,
                      ))
                      ..rotateX(tilt),
                    child: child!,
                  ),
                ),
              );
            },
            child: child,
          );
        },
      ),
    );
  }
}

class _SubscriptionHistoryListItem extends StatelessWidget {
  final Subscription subscription;
  final String currencySymbol;
  final VoidCallback onTap;

  const _SubscriptionHistoryListItem({
    required this.subscription,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = SubscriptionUIHelper.getIcon(subscription.serviceName);
    final isExpired = subscription.status == 'EXPIRED';

    return Hero(
      tag: 'sub_history_${subscription.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.cobaltBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.serviceName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isExpired)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'EXPIRED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}