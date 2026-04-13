import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/features/account/models/user_model.dart';
import '../../auth/widgets/auth_background.dart';
import '../../auth/widgets/auth_header.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../settings/providers/currency_provider.dart';
import '../../navigation/screens/main_scaffold.dart';
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
import '../../../core/auth/auth_service.dart';

class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamically calculate padding to prevent overlap with the transparent AppBar
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 30;
    final householdAsync = ref.watch(householdProvider);
    final userRole = ref.watch(userRoleProvider);

    if (userRole == UserRole.single) {
      return _buildNoHousehold(context, topPadding);
    } else {
      return householdAsync.when(
        data: (household) => _buildActiveHousehold(
          context,
          ref,
          topPadding,
          userRole,
          household,
        ),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => _buildNoHousehold(context, topPadding),
      );
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
                title: 'Get Started',
                subtitle:
                    'Manage your subscriptions with family or roommates in a shared space.',
              ),
              const SizedBox(height: 50),
              SelectionCard(
                title: 'Create a Household',
                description: 'Start a new group and be the administrator.',
                icon: Icons.add_home_work_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateHouseholdScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SelectionCard(
                title: 'Join Household',
                description: 'Enter a code shared by your household admin.',
                icon: Icons.group_add_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinHouseholdScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveHousehold(
    BuildContext context,
    WidgetRef ref,
    double topPadding,
    UserRole userRole,
    Map<String, dynamic>? household,
  ) {
    if (household == null) return _buildNoHousehold(context, topPadding);

    final theme = Theme.of(context);
    final isAdmin = userRole == UserRole.admin;
    final householdName = household['name'] ?? 'Shared Space';
    final members = household['members'] as List<dynamic>? ?? [];
    final currentUser = ref.watch(userProvider).value;

    final subscriptions = ref.watch(subscriptionProvider).value ?? [];
    final currencySymbol = ref.watch(currencySymbolProvider);

    // Calculate totals
    final int totalMembers = members.length;
    final int sharedSubsCount = subscriptions.length;
    final double totalValue = subscriptions.fold(
      0.0,
      (sum, sub) => sum + sub.amount,
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(householdProvider.notifier).refresh(),
      displacement: 20,
      color: theme.primaryColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HouseholdHeroCard(
              householdName: householdName,
              imageUrl: household['imageUrl'],
              isAdmin: isAdmin,
              sharedSubs: sharedSubsCount.toString(),
              totalValue: totalValue,
              currencySymbol: currencySymbol,
              onInviteTap: () => _showInviteBottomSheet(context, householdName),
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
            ...members.map((member) {
              final isYou = member['id'] == currentUser?.id;
              final name = isYou ? 'You' : (member['fullName'] ?? 'Member');
              final role =
                  member['role'] == 'ADMIN' || member['role'] == 'Admin'
                  ? 'Admin'
                  : 'Member';

              return MemberListItem(
                name: name,
                role: role,
                isYou: isYou,
                profilePicture: member['profilePicture'],
                showArrow: isAdmin && !isYou,

                onTap: (isAdmin && !isYou)
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberDetailsScreen(
                            memberId: member['id'],
                            memberName: member['fullName'] ?? 'Member',
                            role: role,
                            householdId: household['id'],
                          ),
                        ),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 40),
            HouseholdActions(
              isAdmin: isAdmin,
              onLeave: () =>
                  _confirmLeave(context, ref, isAdmin, householdName),
              onDelete: () => _confirmDelete(context, ref, householdName),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLeave(
    BuildContext context,
    WidgetRef ref,
    bool isAdmin,
    String householdName,
  ) {
    showDialog(
      context: context,
      builder: (context) => LeaveHouseholdDialog(
        householdName: householdName,
        onConfirm: () async {
          if (isAdmin) {
            // Admin flow: first check for successors
            if (context.mounted) _showTransferAdmin(context, ref);
          } else {
            // Standard member flow: biometrics first, then leave
            final authService = ref.read(authServiceProvider);
            final authenticated = await authService.authenticate();

            if (authenticated) {
              try {
                await ref.read(householdProvider.notifier).leave();
                if (context.mounted) {
                  // Switch to Dashboard tab
                  ref.read(navigationIndexProvider.notifier).setIndex(2);
                  
                  CustomToast.show(
                    context: context,
                    message: 'You have left the household.',
                    isError: true,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  CustomToast.show(
                    context: context,
                    message: 'Error: $e',
                    isError: true,
                  );
                }
              }
            } else {
              if (context.mounted) {
                CustomToast.show(
                  context: context,
                  message: 'Authentication required to leave household',
                  isError: true,
                );
              }
            }
          }
        },
      ),
    );
  }

  void _showTransferAdmin(BuildContext context, WidgetRef ref) {
    final household = ref.read(householdProvider).value;
    final currentUser = ref.read(userProvider).value;

    // Filter eligible members (must be 18+)
    final eligibleMembers = (household?['members'] as List<dynamic>? ?? [])
        .where((m) {
          final isNotYou = m['id'] != currentUser?.id;
          final age = User.getAgeFromJson(m as Map<String, dynamic>);
          return isNotYou && age >= 18;
        })
        .map((m) => m as Map<String, dynamic>)
        .toList();

    if (eligibleMembers.isEmpty) {
      CustomToast.show(
        context: context,
        message:
            'No other adult members available to take over. You must delete the household instead.',
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => TransferAdminDialog(
        members: eligibleMembers,
        onTransferAndLeave: (targetId) async {
          // Authentication Barrier before final destructive action
          final authService = ref.read(authServiceProvider);
          final authenticated = await authService.authenticate();

          if (!authenticated) {
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: 'Authentication required to transfer adminship',
                isError: true,
              );
            }
            return;
          }

          try {
            await ref.read(householdProvider.notifier).transferAdmin(targetId);
            await ref.read(householdProvider.notifier).leave();

            if (context.mounted) {
              // Switch to Dashboard tab
              ref.read(navigationIndexProvider.notifier).setIndex(2);
              
              CustomToast.show(
                context: context,
                message: 'Adminship transferred and you have left.',
              );
            }
          } catch (e) {
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: 'Error: $e',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String householdName,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteHouseholdDialog(
        householdName: householdName,
        onConfirm: () async {
          // Authentication Barrier
          final authService = ref.read(authServiceProvider);
          final authenticated = await authService.authenticate();

          if (!authenticated) {
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: 'Authentication required to delete household',
                isError: true,
              );
            }
            return;
          }

          try {
            await ref.read(householdProvider.notifier).delete();
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: 'Household "$householdName" has been deleted.',
                isError: true,
              );
            }
          } catch (e) {
            if (context.mounted) {
              CustomToast.show(
                context: context,
                message: 'Error: $e',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }

  void _showInviteBottomSheet(BuildContext context, String householdName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteBottomSheet(householdName: householdName),
    );
  }
}
