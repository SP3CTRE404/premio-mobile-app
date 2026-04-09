import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/widgets/auth_background.dart';
import '../../auth/widgets/auth_header.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../settings/providers/currency_provider.dart';
import 'create_household_screen.dart';
import 'join_household_screen.dart';
import 'member_details_screen.dart';
import '../providers/household_provider.dart';
import '../widgets/household_screen/household_hero_card.dart';
import '../widgets/household_screen/member_list_item.dart';
import '../widgets/household_screen/invite_bottom_sheet.dart';
import '../widgets/household_screen/household_actions.dart';
import '../widgets/household_screen/leave_household_dialog.dart';
import '../widgets/household_screen/transfer_admin_dialog.dart';
import '../widgets/household_screen/delete_household_dialog.dart';
import '../widgets/shared/selection_card.dart';
import '../../../core/widgets/custom_toast.dart';

class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamically calculate padding to prevent overlap with the transparent AppBar
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 30;
    final userRole = ref.watch(userRoleProvider);

    if (userRole == UserRole.single) {
      return _buildNoHousehold(context, topPadding);
    } else {
      return _buildActiveHousehold(context, ref, topPadding, userRole);
    }
  }

  Widget _buildNoHousehold(BuildContext context, double topPadding) {
    return Stack(
      children: [
        const AuthBackground(),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, topPadding + 40, 28, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Get\nStarted',
                subtitle: 'Manage your subscriptions with family or roommates in a shared space.',
              ),
              const SizedBox(height: 60),
              SelectionCard(
                title: 'Create Household',
                description: 'Start a new group and invite others to join.',
                icon: Icons.add_home_work_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateHouseholdScreen()),
                ),
              ),
              const SizedBox(height: 20),
              SelectionCard(
                title: 'Join Household',
                description: 'Enter a code shared by your household admin.',
                icon: Icons.group_add_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinHouseholdScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveHousehold(
      BuildContext context, WidgetRef ref, double topPadding, UserRole userRole) {
    final theme = Theme.of(context);
    final isAdmin = userRole == UserRole.admin;

    // Mocked data for modern view
    const int totalMembers = 4;
    const int sharedSubs = 12;
    const double totalValue = 450.0;
    final currencySymbol = ref.watch(currencySymbolProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HouseholdHeroCard(
            householdName: 'Family Track',
            isAdmin: isAdmin,
            sharedSubs: sharedSubs.toString(),
            totalValue: totalValue,
            currencySymbol: currencySymbol,
            onInviteTap: () => _showInviteBottomSheet(context),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members ($totalMembers)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MemberListItem(
            name: 'You',
            role: isAdmin ? 'Admin' : 'Member',
            isYou: true,
            showArrow: false,
          ),
          MemberListItem(
            name: 'Jane Doe', 
            role: 'Member', 
            isYou: false, 
            showArrow: isAdmin,
            onTap: isAdmin ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberDetailsScreen(memberName: 'Jane Doe', role: 'Member'))) : null,
          ),
          MemberListItem(
            name: 'John Smith', 
            role: 'Member', 
            isYou: false, 
            showArrow: isAdmin,
            onTap: isAdmin ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberDetailsScreen(memberName: 'John Smith', role: 'Member'))) : null,
          ),
          MemberListItem(
            name: 'Alice Joy', 
            role: 'Member', 
            isYou: false, 
            showArrow: isAdmin,
            onTap: isAdmin ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberDetailsScreen(memberName: 'Alice Joy', role: 'Member'))) : null,
          ),
          const SizedBox(height: 40),
          HouseholdActions(
            isAdmin: isAdmin,
            onLeave: () => _confirmLeave(context, ref, isAdmin),
            onDelete: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, WidgetRef ref, bool isAdmin) {
    showDialog(
      context: context,
      builder: (context) => LeaveHouseholdDialog(
        householdName: 'Family Track',
        onConfirm: () async {
          if (isAdmin) {
            _showTransferAdmin(context, ref);
          } else {
            try {
              await ref.read(householdProvider.notifier).leave();
              if (context.mounted) {
                CustomToast.show(
                  context: context,
                  message: 'You have left the household.',
                  isError: true,
                );
              }
            } catch (e) {
              if (context.mounted) CustomToast.show(context: context, message: 'Error: $e', isError: true);
            }
          }
        },
      ),
    );
  }

  void _showTransferAdmin(BuildContext context, WidgetRef ref) {
    // Mock members list aside from 'You'
    final members = ['Jane Doe', 'John Smith', 'Alice Joy'];

    showDialog(
      context: context,
      builder: (context) => TransferAdminDialog(
        members: members,
        onTransferAndLeave: (newAdminName) async {
          try {
            // In a real app, you'd get the actual member ID. 
            // For now, using a dummy ID as placeholder.
            await ref.read(householdProvider.notifier).transferAdmin(99); 
            await ref.read(householdProvider.notifier).leave();
            
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: '$newAdminName is now the Admin. You have left.',
              );
            }
          } catch (e) {
            if (context.mounted) CustomToast.show(context: context, message: 'Error: $e', isError: true);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => DeleteHouseholdDialog(
        householdName: 'Family Track',
        onConfirm: () async {
          try {
            await ref.read(householdProvider.notifier).delete();
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: 'Household "Family Track" has been deleted.',
                isError: true,
              );
            }
          } catch (e) {
            if (context.mounted) CustomToast.show(context: context, message: 'Error: $e', isError: true);
          }
        },
      ),
    );
  }

  void _showInviteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InviteBottomSheet(householdName: 'Family Track'),
    );
  }
}
