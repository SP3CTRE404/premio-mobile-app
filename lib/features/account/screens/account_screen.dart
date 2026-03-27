import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/account_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // ── Safe padding to account for the floating transparent AppBar ──
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    // Placeholder logic for household status (In the future, check user.householdId != null)
    const bool hasHousehold = false; 

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Overflowing Profile Header ──
          userAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('Error loading profile: $err', style: TextStyle(color: Colors.red.shade700)),
            ),
            data: (user) {
              if (user == null) return const SizedBox.shrink();

              final initials = user.fullName
                  .split(' ')
                  .where((w) => w.isNotEmpty)
                  .take(2)
                  .map((w) => w[0].toUpperCase())
                  .join();

              return Container(
                margin: const EdgeInsets.only(bottom: 32, top: 12, right: 8),
                child: Stack(
                  clipBehavior: Clip.none, // Allows the avatar to break out of the box
                  alignment: Alignment.bottomCenter, // Centers the overflowing avatar vertically
                  children: [
                    // 1. The tighter background box
                    Container(
                      width: double.infinity,
                      // Reduced vertical padding to make the box shorter
                      // Large right padding ensures text doesn't hide behind the avatar
                      padding: const EdgeInsets.fromLTRB(20, 16, 90, 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 2. The oversized, overflowing avatar
                    Positioned(
                      right: -12, // Pulls the avatar slightly out of the right edge
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            // Creates a cutout effect against the scaffold background
                            color: theme.scaffoldBackgroundColor, 
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 56,
                           // Diameter is 92, which is taller than the box itself
                          backgroundColor: AppColors.cobaltBlue,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Household Management Card (Reverted to original) ──
          _SectionHeader(title: 'My Household'),
          Card(
            color: colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: hasHousehold 
                  ? _buildActiveHouseholdUI(context, theme, colorScheme)
                  : _buildNoHouseholdUI(context, theme, colorScheme),
            ),
          ),

          // ── Support & Feedback (Reverted to original) ──
          _SectionHeader(title: 'Support'),
          Card(
            color: colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── Logout Button (Reverted to original solid red style) ──
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showLogoutConfirmation(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// UI displayed when the user is NOT part of a household
  Widget _buildNoHouseholdUI(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_home_rounded, color: AppColors.cobaltBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Household Yet',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Create or join a household to share subscriptions.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Join Household flow coming soon!')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cobaltBlue,
                  side: const BorderSide(color: AppColors.cobaltBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create Household flow coming soon!')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cobaltBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// UI displayed when the user IS part of a household
  Widget _buildActiveHouseholdUI(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.house_rounded, color: AppColors.cobaltBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Track', // Placeholder for actual household name
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'You and 3 others',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Household management coming soon!')),
              );
            },
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Manage Household'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cobaltBlue,
              side: const BorderSide(color: AppColors.cobaltBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of SubTrack?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for consistent section headers
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}