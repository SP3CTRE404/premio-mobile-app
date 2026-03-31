import 'package:flutter/material.dart';
import '../widgets/household_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_block.dart';
import '../widgets/support_card.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 30;
    const bool hasHousehold = false;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileHeader(),
          const SizedBox(height: 28),
          const SectionBlock(
            title: 'My Household',
            child: HouseholdCard(hasHousehold: hasHousehold),
          ),
          const SizedBox(height: 20),
          const SectionBlock(
            title: 'Support',
            child: SupportCard(),
          ),
          const SizedBox(height: 32),
          const LogoutButton(),
        ],
      ),
    );
  }
}