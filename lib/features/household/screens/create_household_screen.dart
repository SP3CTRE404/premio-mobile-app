import 'package:flutter/material.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../auth/widgets/auth_button.dart';
import '../widgets/shared/household_form_layout.dart';

class CreateHouseholdScreen extends StatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  State<CreateHouseholdScreen> createState() => _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends State<CreateHouseholdScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HouseholdFormLayout(
      title: 'Create\nHousehold',
      subtitle: 'Start a shared space for your subscriptions with family or friends.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Household Name',
            hint: 'e.g. Smith Family',
            controller: _nameController,
          ),
          const SizedBox(height: 32),
          AuthButton(
            label: 'Create',
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
