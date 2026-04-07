import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/widgets/auth_background.dart';
import '../../auth/widgets/auth_header.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../settings/providers/currency_provider.dart';
import 'create_household_screen.dart';
import 'join_household_screen.dart';
import '../widgets/household_screen/household_hero_card.dart';
import '../widgets/household_screen/member_list_item.dart';
import '../widgets/household_screen/invite_bottom_sheet.dart';
import '../widgets/household_screen/household_actions.dart';
import '../widgets/household_screen/leave_household_dialog.dart';
import '../widgets/shared/selection_card.dart';

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
            showArrow: isAdmin,
          ),
          MemberListItem(name: 'Jane Doe', role: 'Member', isYou: false, showArrow: isAdmin),
          MemberListItem(name: 'John Smith', role: 'Member', isYou: false, showArrow: isAdmin),
          MemberListItem(name: 'Alice Joy', role: 'Member', isYou: false, showArrow: isAdmin),
          const SizedBox(height: 40),
          HouseholdActions(
            isAdmin: isAdmin,
            onLeave: () => _confirmLeave(context),
            onDelete: () {
              // TODO: Delete household logic
            },
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LeaveHouseholdDialog(
        householdName: 'Family Track',
        onConfirm: () {
          // TODO: Actually leave household logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You have left the household.'),
              backgroundColor: AppColors.neonRed,
            ),
          );
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
