import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../auth/widgets/auth_button.dart';
import '../widgets/shared/household_form_layout.dart';
import '../providers/household_provider.dart';
import '../../../core/widgets/custom_toast.dart';

class CreateHouseholdScreen extends ConsumerStatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  ConsumerState<CreateHouseholdScreen> createState() => _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends ConsumerState<CreateHouseholdScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

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
            label: _isLoading ? 'Creating...' : 'Create',
            onPressed: _isLoading ? null : () async { 
              if (_nameController.text.trim().isEmpty) return;
              
              setState(() => _isLoading = true);
              try {
                await ref.read(householdProvider.notifier).createHousehold(_nameController.text.trim());
                if (context.mounted) {
                  CustomToast.show(context: context, message: 'Household created successfully!');
                  Navigator.pop(context); // Go back after success
                }
              } catch (e) {
                if (context.mounted) CustomToast.show(context: context, message: e.toString(), isError: true);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
