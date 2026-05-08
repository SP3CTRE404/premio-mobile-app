import 'package:flutter/material.dart';
import 'package:subtrack/features/settings/providers/currency_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/widgets/auth_background.dart';
import '../../subscriptions/models/subscription_model.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../subscriptions/widgets/subscription_detail/subscription_card.dart';

import '../widgets/member_details_screen/member_details_app_bar.dart';
import '../widgets/member_details_screen/member_profile_header.dart';
import '../widgets/member_details_screen/admin_action_pill.dart';

class MemberDetailsScreen extends ConsumerStatefulWidget {
  final int memberId;
  final String memberName;
  final String role;
  final int? householdId;


  const MemberDetailsScreen({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.role,
    this.householdId,
  });


  @override
  ConsumerState<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends ConsumerState<MemberDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final Set<int> _expandedSubs = {};

  void _toggleExpand(int subId) {
    setState(() {
      if (_expandedSubs.contains(subId)) {
        _expandedSubs.remove(subId);
      } else {
        _expandedSubs.add(subId);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final isScrolled = _scrollController.offset > 10;
        if (isScrolled != _isScrolled) {
          setState(() {
            _isScrolled = isScrolled;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = ref.watch(userRoleProvider);
    final isAdmin = userRole == UserRole.admin;

    final subscriptions = ref.watch(subscriptionProvider).value ?? [];
    final List<Subscription> memberSubs = subscriptions
        .where((s) => s.ownerId == widget.memberId)
        .toList();


    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: MemberDetailsAppBar(
        memberId: widget.memberId,
        memberName: widget.memberName,
        isAdmin: isAdmin,
        isScrolled: _isScrolled,
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 120.0),
            child: Column(
              children: [
                // Profile Section
                MemberProfileHeader(
                  memberId: widget.memberId,
                  memberName: widget.memberName,
                  role: widget.role,
                ),
                const SizedBox(height: 32),
                
                // Subscriptions List
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Member's Subscriptions",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ...memberSubs.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SubscriptionCard(
                      subscription: sub,
                      currencySymbol: ref.watch(nativeCurrencyProvider),
                      isExpanded: _expandedSubs.contains(sub.id),
                      onTap: () => _toggleExpand(sub.id),
                      showMadeBy: false,
                    ),
                  );
                }),


              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin 
          ? AdminActionPill(
              memberId: widget.memberId,
              memberName: widget.memberName,
            ) 
          : null,
    );
  }
}
