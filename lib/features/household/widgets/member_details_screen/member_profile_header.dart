import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/household_provider.dart';

class MemberProfileHeader extends ConsumerWidget {
  final int memberId;
  final String memberName;
  final String role;

  const MemberProfileHeader({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Create consistent avatar based on name hash
    final avatarColors = [
      Colors.purpleAccent,
      Colors.deepOrangeAccent,
      Colors.tealAccent.shade400,
      AppColors.cobaltBlue,
    ];
    final colorHash = memberName.hashCode.abs() % avatarColors.length;
    final avatarColor = avatarColors[colorHash];

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [avatarColor.withValues(alpha: 0.8), avatarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: avatarColor.withValues(alpha: 0.3), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              final members = ref.watch(householdProvider).value?['members'] as List<dynamic>?;
              final member = members?.firstWhere((m) => m['id'] == memberId, orElse: () => null);
              final pfp = member?['profilePicture'];

              if (pfp != null && pfp.toString().isNotEmpty) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.memory(
                    base64Decode(pfp.toString().split(',').last),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                );
              }

              return Center(
                child: Text(
                  memberName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          memberName,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: role == 'Admin' 
                ? AppColors.cobaltBlue.withValues(alpha: 0.1) 
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: theme.textTheme.labelMedium?.copyWith(
              color: role == 'Admin' 
                  ? AppColors.cobaltBlue 
                  : colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
