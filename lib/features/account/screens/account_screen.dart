import 'package:flutter/material.dart';

import '../widgets/household_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_header.dart';
import '../widgets/support_card.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Safe padding to account for the floating transparent AppBar ──
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    
    // Placeholder logic for household status (In the future, check user.householdId != null)
    const bool hasHousehold = false;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileHeader(),
          SectionHeader(title: 'My Household'),
          HouseholdCard(hasHousehold: hasHousehold),
          SectionHeader(title: 'Support'),
          SupportCard(),
          LogoutButton(),
        ],
      ),
    );
  }
}
