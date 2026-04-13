import 'package:flutter/material.dart';
import '../../../subscriptions/screens/add_subscription_screen.dart';
import '../../../subscriptions/screens/edit_subscriptions_screen.dart';

class AdminActionPill extends StatelessWidget {
  final int memberId;
  final String memberName;

  const AdminActionPill({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (_) => EditSubscriptionsScreen(memberName: memberName)),
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
                    targetUserId: memberId,
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
