import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../account/providers/account_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../screens/main_scaffold.dart';

class SubTrackDrawer extends ConsumerWidget {
  const SubTrackDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final currentIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // ── Header: User Profile ──
          _buildHeader(context, userAsync),

          // ── Body: Navigation Links ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerTile(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isSelected: currentIndex == 0,
                  onTap: () => _onNavTap(context, ref, 0),
                ),
                _DrawerTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Due Soon',
                  isSelected: currentIndex == 1,
                  onTap: () => _onNavTap(context, ref, 1),
                ),

                const Divider(indent: 20, endIndent: 20),
                _DrawerTile(
                  icon: Icons.house_outlined,
                  label: 'My Household',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Household Management
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Footer: Logout ──
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () => _handleLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue userAsync) {
    return userAsync.when(
      data: (user) {
        final initials = user?.fullName.split(' ').take(2).map((e) => e[0]).join().toUpperCase() ?? '??';
        return UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: Colors.transparent),
          currentAccountPicture: CircleAvatar(
            backgroundColor: AppColors.cobaltBlue,
            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          accountName: Text(user?.fullName ?? 'User', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          accountEmail: Text(user?.email ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        );
      },
      loading: () => const DrawerHeader(child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const DrawerHeader(child: Center(child: Icon(Icons.error))),
    );
  }

  void _onNavTap(BuildContext context, WidgetRef ref, int index) {
    ref.read(navigationIndexProvider.notifier).setIndex(index);
    Navigator.pop(context);
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.cobaltBlue : null),
      title: Text(label, style: TextStyle(color: isSelected ? AppColors.cobaltBlue : null, fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      onTap: onTap,
    );
  }
}