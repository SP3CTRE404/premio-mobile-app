import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/app_lock_provider.dart';

class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAppLockEnabledAsync = ref.watch(appLockProvider);

    return isAppLockEnabledAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Card(child: ListTile(title: Text('App Lock'), trailing: CircularProgressIndicator())),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (isAppLockEnabled) => Column(
        children: [
          // App Lock Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: colorScheme.surface,
              child: ListTile(
                leading: Icon(
                  isAppLockEnabled ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                  color: AppColors.cobaltBlue,
                ),
                title: const Text('App Lock'),
                subtitle: Text(
                  isAppLockEnabled 
                      ? 'Secured with your phone authentication' 
                      : 'Protect your app with biometrics or PIN',
                ),
                trailing: Switch.adaptive(
                  value: isAppLockEnabled,
                  activeTrackColor: AppColors.cobaltBlue.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.cobaltBlue,
                  onChanged: (value) {
                    ref.read(appLockProvider.notifier).setAppLockEnabled(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
