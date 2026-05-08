import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/subscription_model.dart';
import '../providers/history_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/subscription_ui_helper.dart';
import '../widgets/history/payment_history_list_view.dart';
import '../widgets/history/subscription_history_bubble.dart';

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
    
    // Account for the MainScaffold's transparent AppBar
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 40;

    return _buildSubscriptionList(activeAsync, expiredAsync, currencySymbol, topPadding);
  }

  Widget _buildSubscriptionList(
    AsyncValue<List<Subscription>> activeAsync,
    AsyncValue<List<Subscription>> expiredAsync,
    String currencySymbol,
    double topPadding,
  ) {
    if (activeAsync.isLoading || expiredAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeItems = activeAsync.value ?? [];
    final expiredItems = expiredAsync.value ?? [];
    final allItems = [...activeItems, ...expiredItems];

    if (allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Text('No subscriptions found.'),
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
        return _SubscriptionHistoryListItem(
          subscription: sub,
          currencySymbol: currencySymbol,
          onTap: () => _showHistoryBubble(sub, currencySymbol),
        );
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
                const Icon(Icons.history_rounded, color: AppColors.cobaltBlue, size: 20),
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