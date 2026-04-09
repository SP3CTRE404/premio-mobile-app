import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/widgets/auth_background.dart';
import '../../subscriptions/models/subscription_model.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../subscriptions/screens/add_subscription_screen.dart';
import '../../subscriptions/screens/edit_subscriptions_screen.dart';
import '../../subscriptions/utils/subscription_ui_helper.dart';
import '../../../../core/theme/app_colors.dart';

class MemberDetailsScreen extends ConsumerStatefulWidget {
  final String memberName;
  final String role;
  final int? householdId;

  const MemberDetailsScreen({
    super.key,
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
    final colorScheme = theme.colorScheme;
    final userRole = ref.watch(userRoleProvider);
    final isAdmin = userRole == UserRole.admin;
    
    // Create consistent avatar based on name hash
    final avatarColors = [
      Colors.purpleAccent,
      Colors.deepOrangeAccent,
      Colors.tealAccent.shade400,
      AppColors.cobaltBlue,
    ];
    final colorHash = widget.memberName.hashCode.abs() % avatarColors.length;
    final avatarColor = avatarColors[colorHash];

    // Simulated subscriptions using real model type
    final List<Subscription> memberSubs = [
      Subscription(
        id: 101,
        serviceName: 'Netflix Family',
        amount: 15.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 5)),
        isAutoPay: true,
        ownerName: widget.memberName,
      ),
      Subscription(
        id: 102,
        serviceName: 'Spotify Duo',
        amount: 12.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 12)),
        isAutoPay: true,
        ownerName: widget.memberName,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Member Details',
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
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 120.0),
            child: Column(
              children: [
                // Profile Section
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [avatarColor.withValues(alpha: 0.8), avatarColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withValues(alpha: 0.3), 
                            blurRadius: 10, 
                            offset: const Offset(0, 4)
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.memberName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 32, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.memberName,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.role == 'Admin' 
                            ? AppColors.cobaltBlue.withValues(alpha: 0.1) 
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.role,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: widget.role == 'Admin' 
                              ? AppColors.cobaltBlue 
                              : colorScheme.onSurface.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                  final icon = SubscriptionUIHelper.getIcon(sub.serviceName);
                  final cycle = sub.billingCycle.name[0].toUpperCase() + sub.billingCycle.name.substring(1);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: AppColors.cobaltBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.serviceName,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cycle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6)
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${sub.amount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, 
                            color: AppColors.cobaltBlue
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin ? _buildAdminPill(context) : null,
    );
  }

  Widget _buildAdminPill(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.1),
              width: 0.8,
            ),
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPillButton(
                context,
                icon: Icons.edit_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditSubscriptionsScreen(memberName: widget.memberName)),
                ),
              ),
              Container(
                width: 0.8,
                height: 20,
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.1),
              ),
              _buildPillButton(
                context,
                icon: Icons.add_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddSubscriptionScreen(
                      targetHouseholdId: widget.householdId ?? 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildPillButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        highlightColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            icon, 
            color: isDark ? Colors.white : theme.colorScheme.onSurface, 
            size: 24
          ),
        ),
      ),
    );
  }
}

