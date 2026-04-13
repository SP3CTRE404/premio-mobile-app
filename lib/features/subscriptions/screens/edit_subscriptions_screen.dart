import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth/widgets/auth_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../../account/providers/account_provider.dart';
import 'add_subscription_screen.dart';
import '../models/subscription_model.dart';
import '../widgets/edit_subscription/edit_subscription_card.dart';
import '../widgets/edit_subscription/subscription_search_bar.dart';
import '../widgets/edit_subscription/end_subscription_dialog.dart';
import '../widgets/edit_subscription/delete_subscription_dialog.dart';

class EditSubscriptionsScreen extends ConsumerStatefulWidget {

  final String? memberName;
  const EditSubscriptionsScreen({super.key, this.memberName});

  @override
  ConsumerState<EditSubscriptionsScreen> createState() => _EditSubscriptionsScreenState();
}

class _EditSubscriptionsScreenState extends ConsumerState<EditSubscriptionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";
  bool _isScrolled = false;

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
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _confirmEndSubscription(Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => EndSubscriptionDialog(
        sub: sub,
        onConfirm: () {}, // Handled internally by dialog now
      ),
    );
  }


  void _confirmDeleteSubscription(Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => DeleteSubscriptionDialog(sub: sub),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);
    final subscriptionsAsync = ref.watch(subscriptionProvider);
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.memberName != null ? 'Edit ${widget.memberName}\'s Subs' : 'Manage Subscriptions', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                offset: const Offset(0, 1),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.3),
                      theme.colorScheme.surface.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          
          subscriptionsAsync.when(
            data: (allSubs) {
              final userFullName = userAsync.value?.fullName ?? '';
              final targetUser = widget.memberName ?? userFullName;
              
              final filteredSubs = allSubs.where((sub) {
                final matchesSearch = sub.serviceName.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesUser = sub.ownerName == targetUser;
                return matchesSearch && matchesUser;
              }).toList();

              if (filteredSubs.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(child: Text('No subscriptions found.'));
              }

              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, 120, 16, 140 + bottomInset),
                itemCount: filteredSubs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sub = filteredSubs[index];
                  return EditSubscriptionCard(
                    sub: sub,
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSubscriptionScreen(initialData: sub),
                      ),
                    ),
                    onEnd: () => _confirmEndSubscription(sub),
                    onDelete: () => _confirmDeleteSubscription(sub),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),

          SubscriptionSearchBar(
            controller: _searchController,
            query: _searchQuery,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ],
      ),
    );
  }
}

