import 'package:flutter/material.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../auth/widgets/auth_button.dart';
import '../widgets/shared/household_form_layout.dart';

class JoinHouseholdScreen extends StatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  State<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends State<JoinHouseholdScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HouseholdFormLayout(
      title: 'Join\nHousehold',
      subtitle: 'Enter the invite code shared by your household administrator.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Invite Code',
            hint: 'Enter 6-digit code',
            controller: _codeController,
          ),
          const SizedBox(height: 32),
          AuthButton(
            label: 'Join',
            onPressed: () { 
              // TODO: Logic to call backend
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
