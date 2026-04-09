import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/account_provider.dart';
import '../../screens/edit_profile_screen.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return userAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text('Error loading profile: $err', style: TextStyle(color: Colors.red.shade700)),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final initials = user.fullName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

        // Safely parse Base64 image
        ImageProvider? getAvatar() {
          if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
            try {
              final base64String = user.profilePicture!.split(',').last;
              return MemoryImage(base64Decode(base64String));
            } catch (e) {
              return null;
            }
          }
          return null;
        }

        final avatarImage = getAvatar();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Dynamic Avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.cobaltBlue,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                },
                icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}