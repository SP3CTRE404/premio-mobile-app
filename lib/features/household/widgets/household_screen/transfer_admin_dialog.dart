import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TransferAdminDialog extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final ValueChanged<int> onTransferAndLeave;

  const TransferAdminDialog({
    super.key,
    required this.members,
    required this.onTransferAndLeave,
  });

  @override
  State<TransferAdminDialog> createState() => _TransferAdminDialogState();
}

class _TransferAdminDialogState extends State<TransferAdminDialog> {
  int? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Make Someone the new Admin',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Since you are the admin, you must choose another adult member to take over before leaving.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
            child: RadioGroup<int>(
              groupValue: _selectedMemberId,
              onChanged: (val) {
                setState(() {
                  _selectedMemberId = val;
                });
              },
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.members.length,
                itemBuilder: (context, index) {
                  final member = widget.members[index];
                  final id = member['id'] as int;
                  final name = member['fullName'] as String? ?? 'Member';

                  return RadioListTile<int>(
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: id,
                    activeColor: AppColors.cobaltBlue,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                },
              ),
            ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _selectedMemberId != null
              ? () {
                  Navigator.pop(context);
                  widget.onTransferAndLeave(_selectedMemberId!);
                }
              : null, // Disabled if no member is selected
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cobaltBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Transfer & Leave',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}
