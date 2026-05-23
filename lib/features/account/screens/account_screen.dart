import 'package:flutter/material.dart';
import '../widgets/account_screen/logout_button.dart';
import '../widgets/account_screen/management_card.dart';
import '../widgets/account_screen/profile_header.dart';
import '../widgets/account_screen/section_block.dart';
import '../widgets/account_screen/support_card.dart';
import '../../tutorial/widgets/tutorial_anchor.dart';
import '../../tutorial/widgets/tutorial_bubble.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate padding to prevent overlap with the transparent AppBar
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 30;
    return SizedBox.expand(
      // Forces the screen to take up the full height, preventing layout jumps
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
        child: Align(
          // Anchors the constrained box to the top center
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TutorialAnchor(
                  tutorialId: 'bottom_nav_account',
                  title: 'Account Settings',
                  description: 'Manage your profile details, currency preferences, and other settings. You can also replay this onboarding tour at any time.',
                  arrowDirection: ArrowDirection.up,
                  child: ProfileHeader(),
                ),
                SizedBox(height: 28),
                SectionBlock(
                  title: 'Management',
                  child: ManagementCard(),
                ),
                SizedBox(height: 28),
                SectionBlock(
                  title: 'Support',
                  child: SupportCard(),
                ),
                SizedBox(height: 32),
                LogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}