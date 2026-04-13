import 'package:flutter/material.dart';

import '../../models/subscription_model.dart';
import '../../utils/subscription_ui_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class EditSubscriptionCard extends StatelessWidget {
  final Subscription sub;
  final VoidCallback onEdit;
  final VoidCallback onEnd;
  final VoidCallback onDelete;

  const EditSubscriptionCard({
    super.key,
    required this.sub,
    required this.onEdit,
    required this.onEnd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final IconData icon = SubscriptionUIHelper.getIcon(sub.serviceName);
    final Color statusColor = SubscriptionUIHelper.getStatusColor(
      isOverdue: sub.isOverdue,
      isUpcoming: sub.isUpcoming,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(sub.amount, '₹'),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            onPressed: onEdit,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cobaltBlue.withValues(alpha: 0.1),
              foregroundColor: AppColors.cobaltBlue,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            onPressed: onDelete,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.neonRed.withValues(alpha: 0.1),
              foregroundColor: AppColors.neonRed,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onEnd,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.neonRed.withValues(alpha: 0.1),
              foregroundColor: AppColors.neonRed,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'End',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

