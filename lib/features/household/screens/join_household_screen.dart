import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../auth/widgets/auth_button.dart';
import '../widgets/shared/household_form_layout.dart';
import 'qr_scanner_screen.dart';
import '../../../core/widgets/custom_toast.dart';
import '../providers/household_provider.dart';

class JoinHouseholdScreen extends ConsumerStatefulWidget {
  final String? initialCode;
  const JoinHouseholdScreen({super.key, this.initialCode});

  @override
  ConsumerState<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends ConsumerState<JoinHouseholdScreen> {
  late final TextEditingController _codeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode);
  }

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
            hint: 'Enter 8-digit code',
            controller: _codeController,
          ),
          const SizedBox(height: 32),
          AuthButton(
            label: _isLoading ? 'Joining...' : 'Join with Code',
            onPressed: _isLoading ? null : () async { 
              if (_codeController.text.trim().isEmpty) return;
              
              setState(() => _isLoading = true);
              try {
                await ref.read(householdProvider.notifier).joinHousehold(_codeController.text.trim());
                if (context.mounted) {
                  CustomToast.show(context: context, message: 'Successfully joined household!');
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) CustomToast.show(context: context, message: e.toString(), isError: true);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
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
                // If the scanned result is a full link, extract the code
                String code = result;
                if (result.contains('/join/')) {
                   code = result.split('/').last;
                }

                setState(() {
                  _codeController.text = code;
                  _isLoading = true;
                });
                
                try {
                  await ref.read(householdProvider.notifier).joinHousehold(code);
                  if (context.mounted) {
                    CustomToast.show(context: context, message: 'Successfully joined household!', isError: false);
                    Navigator.pop(context);
                  }
                } catch (e) {
                   String errorMessage = e.toString();
                   if (errorMessage.toLowerCase().contains('already')) {
                     errorMessage = 'You are already in a household. Leave your current one first.';
                   } else if (errorMessage.toLowerCase().contains('invalid') || errorMessage.toLowerCase().contains('not found')) {
                     errorMessage = 'This invite code is invalid or has expired.';
                   }
                  if (context.mounted) CustomToast.show(context: context, message: errorMessage, isError: true);
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
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
