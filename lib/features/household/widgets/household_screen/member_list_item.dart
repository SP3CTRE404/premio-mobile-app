import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MemberListItem extends StatelessWidget {
  final String name;
  final String role;
  final bool isYou;
  final bool showArrow;
  final String? profilePicture;
  final VoidCallback? onTap;

  const MemberListItem({
    super.key,
    required this.name,
    required this.role,
    required this.isYou,
    this.showArrow = true,
    this.profilePicture,
    this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Create consistent avatars
    final avatarColors = [
      Colors.purpleAccent,
      Colors.deepOrangeAccent,
      Colors.tealAccent.shade400,
      AppColors.cobaltBlue,
    ];
    final colorHash = name.hashCode.abs() % avatarColors.length;
    final avatarColor = isYou ? AppColors.cobaltBlue : avatarColors[colorHash];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    avatarColor.withValues(alpha: 0.8),
                    avatarColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: (profilePicture != null && profilePicture!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.memory(
                        base64Decode(
                          profilePicture!.contains(',') 
                              ? profilePicture!.split(',').last 
                              : profilePicture!
                        ),
                        fit: BoxFit.cover,
                      ),
                    )

                  : Center(
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isYou) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'You',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        role == 'Admin' ? Icons.shield_rounded : Icons.person_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        role,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }
}
