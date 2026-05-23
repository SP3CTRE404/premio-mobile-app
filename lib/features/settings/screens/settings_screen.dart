import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/features/auth/providers/auth_provider.dart';

import '../../../core/auth/auth_service.dart';
import '../../../shared/widgets/custom_toast.dart';
import '../../account/models/user_model.dart';
import '../../account/providers/account_provider.dart';
import '../../household/providers/household_provider.dart';
import '../../household/widgets/household_screen/transfer_admin_dialog.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../widgets/about_section.dart';
import '../widgets/look_and_feel_section.dart';
import '../widgets/security_section.dart';
import '../../../../shared/widgets/app_section_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
    // Proactively watch these providers to ensure data is fresh and loaded
    // as soon as the SettingsScreen is displayed.
    ref.watch(userRoleProvider);
    ref.watch(householdProvider);

    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
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
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          0,
          MediaQuery.of(context).padding.top + kToolbarHeight + 8,
          0,
          40,
        ),
        children: [
          const AppSectionHeader(title: 'Look and Feel', isUppercase: true),
          const LookAndFeelSection(),
          const SizedBox(height: 12),


          const AppSectionHeader(title: 'Security', isUppercase: true),
          const SecuritySection(),
          const SizedBox(height: 12),

          const AppSectionHeader(title: 'Account Management', isUppercase: true),
          
          // Logout Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                leading: Icon(Icons.logout_rounded, color: theme.colorScheme.onSurface),
                title: const Text(
                  'Sign out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Sign out of your account'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _handleLogout(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.red.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person_remove_rounded, color: Colors.red),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Permanently remove your data'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
                    onTap: () => _handleDeleteAccount(context, ref),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const AppSectionHeader(title: 'About', isUppercase: true),
          const AboutSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    // 0. Ensure Data Readiness
    // If the household data is still loading, wait for it before evaluating role logic.
    final householdAsync = ref.read(householdProvider);
    if (householdAsync.isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      // Wait for data to finish loading
      await ref.read(householdProvider.future);
      if (context.mounted) Navigator.pop(context); // Remove loader
    }

    if (!context.mounted) return;
    final userRole = ref.read(userRoleProvider);
    final household = ref.read(householdProvider).value;
    final currentUser = ref.read(userProvider).value;

    // 1. Check if Admin Transfer is needed
    // This step MUST happen first to prevent orphaned households.
    if (userRole == UserRole.admin) {
      final members = household?['members'] as List<dynamic>? ?? [];
      
      // Filter eligible members (must be 18+ and not the current user)
      final eligibleMembers = members.where((m) {
        final isNotYou = m['id'] != currentUser?.id;
        final age = User.getAgeFromJson(m as Map<String, dynamic>);
        return isNotYou && age >= 18;
      }).map((m) => m as Map<String, dynamic>).toList();

      if (eligibleMembers.isNotEmpty) {
        // Show Transfer Admin Dialog
        final success = await showDialog<bool>(
          context: context,
          builder: (context) => TransferAdminDialog(
            members: eligibleMembers,
            onTransferAndLeave: (targetId) async {
              try {
                await ref.read(householdProvider.notifier).transferAdmin(targetId);
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) CustomToast.show(context: context, message: 'Transfer failed: $e', isError: true);
                if (context.mounted) Navigator.pop(context, false);
              }
            },
          ),
        );

        if (success != true) return; // User cancelled or transfer failed
      }
    }

    // 2. Final Confirmation Dialog
    // Now that any admin requirements are settled, ask for final confirmation.
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and will wipe all your data from our servers. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // 3. Mandatory Biometric/Native Authentication
    // Auth MUST be the last barrier!
    final authService = ref.read(authServiceProvider);
    final authenticated = await authService.verifyUser(context);

    if (!authenticated) {
      if (context.mounted) CustomToast.show(context: context, message: 'Authentication required to delete account', isError: true);
      return;
    }

    // 4. Execution
    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      await ref.read(userProvider.notifier).deleteAccount();
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        CustomToast.show(context: context, message: 'Account deleted successfully', isError: true);
        // Navigation is now handled reactively by the listener in main.dart
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        CustomToast.show(context: context, message: 'Deletion failed: $e', isError: true);
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(authProvider.notifier).logout();
      // Navigation is now handled reactively by the listener in main.dart
    } catch (e) {
      if (context.mounted) {
        CustomToast.show(context: context, message: 'Logout failed: $e', isError: true);
      }
    }
  }
}
