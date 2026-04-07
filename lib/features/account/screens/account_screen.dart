import 'package:flutter/material.dart';
import '../widgets/account_screen/logout_button.dart';
import '../widgets/account_screen/profile_header.dart';
import '../widgets/account_screen/section_block.dart';
import '../widgets/account_screen/support_card.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ProfileHeader(),
                const SizedBox(height: 28),
                const SectionBlock(
                  title: 'Support',
                  child: SupportCard(),
                ),
                const SizedBox(height: 32),
                const LogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}