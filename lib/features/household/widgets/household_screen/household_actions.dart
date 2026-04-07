import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HouseholdActions extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onLeave;
  final VoidCallback? onDelete;

  const HouseholdActions({
    super.key,
    required this.isAdmin,
    this.onLeave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onLeave,
              icon: const Icon(Icons.exit_to_app_rounded),
              label: const Text('Leave'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neonRed,
                side: const BorderSide(color: AppColors.neonRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Delete'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.neonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLeave,
        icon: const Icon(Icons.exit_to_app_rounded),
        label: const Text('Leave Household'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonRed,
          side: const BorderSide(color: AppColors.neonRed),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
