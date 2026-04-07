import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dashboard/models/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/widgets/auth_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_subscription_screen.dart';
import '../widgets/edit_subscription/edit_subscription_card.dart';
import '../widgets/edit_subscription/subscription_search_bar.dart';
import '../widgets/edit_subscription/end_subscription_dialog.dart';

class EditSubscriptionsScreen extends ConsumerStatefulWidget {
  const EditSubscriptionsScreen({super.key});

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

  void _confirmEndSubscription(MockSub sub) {
    showDialog(
      context: context,
      builder: (context) => EndSubscriptionDialog(
        sub: sub,
        onConfirm: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription to ${sub.name} ended.'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filteredSubs = mockSubs.where((sub) {
      return sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Manage Subscriptions', 
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
          
          filteredSubs.isEmpty && _searchQuery.isNotEmpty
              ? const Center(child: Text('No subscriptions found.'))
              : ListView.separated(
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
                    );
                  },
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
