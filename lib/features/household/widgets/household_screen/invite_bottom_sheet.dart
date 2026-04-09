import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toast.dart';
import '../../providers/household_provider.dart';

class InviteBottomSheet extends ConsumerWidget {
  final String householdName;

  const InviteBottomSheet({
    super.key,
    required this.householdName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final household = ref.watch(householdProvider).value;
    final inviteCode = household?['inviteCode'] ?? 'LOADING...';
    final shareLink = 'https://subtrack.app/join/$inviteCode';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 12,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.diversity_3_rounded,
                  color: AppColors.cobaltBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Invite to $householdName',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Share Link Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Share Link',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 20, color: AppColors.cobaltBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    shareLink,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.cobaltBlue,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shareLink));
                    if (context.mounted) {
                      CustomToast.show(context: context, message: 'Link copied to clipboard', isError: false);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 20),
                  onPressed: () {
                    Share.share(
                      'Join my household on SubTrack! $shareLink',
                      subject: 'Join my SubTrack Household',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ),
              Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
            ],
          ),
          const SizedBox(height: 24),

          // Invite Code Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Invite Code',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  inviteCode.toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: inviteCode));
                    if (context.mounted) {
                      CustomToast.show(context: context, message: 'Code copied to clipboard', isError: false);
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 22),
                  color: AppColors.cobaltBlue,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cobaltBlue.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // QR Reveal
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showQRDialog(context, theme, shareLink),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Show QR Code'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                foregroundColor: theme.colorScheme.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRDialog(BuildContext context, ThemeData theme, String shareLink) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan to Join',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: shareLink,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
