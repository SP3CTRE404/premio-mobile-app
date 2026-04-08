import 'package:flutter/material.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../auth/widgets/auth_button.dart';
import '../widgets/shared/household_form_layout.dart';
import 'qr_scanner_screen.dart';
import '../../../core/widgets/custom_toast.dart';

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
            label: 'Join with Code',
            onPressed: () { 
              // TODO: Logic to call backend
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrScannerScreen(),
                ),
              );

              if (result != null && result.isNotEmpty && context.mounted) {
                setState(() {
                  _codeController.text = result;
                });
                
                // Optionally show a quick visual confirmation
                CustomToast.show(context: context, message: 'QR Code Scanned Successfully!', isError: false);
              }
            },
            icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.onSurface),
            label: Text('Scan QR Code', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
        ],
      ),
    );
  }
}
