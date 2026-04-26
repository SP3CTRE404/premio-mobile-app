import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_service.dart';
import '../../providers/household_provider.dart';
import '../../../account/providers/account_provider.dart';
import '../../../account/screens/expired_subscriptions_screen.dart';
import '../../../subscriptions/screens/payment_history_screen.dart';

class MemberDetailsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int memberId;
  final String memberName;
  final bool isAdmin;
  final bool isScrolled;

  const MemberDetailsAppBar({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.isAdmin,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppBar(
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
      actions: [
        if (isAdmin && memberId != ref.read(userProvider).value?.id)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) async {
              if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHistoryScreen(
                      memberId: memberId,
                      memberName: memberName,
                    ),
                  ),
                );
              } else if (value == 'expired') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpiredSubscriptionsScreen(
                      memberId: memberId,
                      memberName: memberName,
                    ),
                  ),
                );
              } else if (value == 'remove') {
                // Authentication required!
                final authService = ref.read(authServiceProvider);
                final authenticated = await authService.authenticate();
                
                if (authenticated) {
                  if (!context.mounted) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove Member?'),
                      content: Text('Are you sure you want to remove $memberName from the household?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await ref.read(householdProvider.notifier).removeMember(memberId);
                      if (context.mounted) {
                        Navigator.pop(context); // Go back after removal
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$memberName removed')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('View History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'expired',
                child: Row(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('View Expired'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Remove Member', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: AnimatedOpacity(
        opacity: isScrolled ? 1.0 : 0.0,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
