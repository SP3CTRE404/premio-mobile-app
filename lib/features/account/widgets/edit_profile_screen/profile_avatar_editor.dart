import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAvatarEditor extends StatelessWidget {
  final String initial;
  final VoidCallback onEdit;

  const ProfileAvatarEditor({
    super.key,
    required this.initial,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 64,
            backgroundColor: AppColors.cobaltBlue.withValues(alpha: 0.1),
            child: Text(
              initial.isNotEmpty ? initial[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.cobaltBlue,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cobaltBlue,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 3),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              onPressed: onEdit,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }
}
