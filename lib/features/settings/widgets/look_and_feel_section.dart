import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/features/account/models/user_model.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../../shared/widgets/custom_toast.dart';

/// Look & Feel section: currency picker + theme toggle.
class LookAndFeelSection extends ConsumerWidget {
  const LookAndFeelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentCurrency = ref.watch(displayCurrencyProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Country/Region Picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            color: colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.public_rounded, color: AppColors.cobaltBlue),
              title: const Text('Region / Country'),
              subtitle: userAsync.when(
                data: (u) => Text(
                  u?.country ?? 'Not set',
                  style: TextStyle(
                    color: u?.country == null ? theme.colorScheme.error : null,
                  ),
                ),
                loading: () => const Text('Loading...'),
                error: (_, _) => const Text('Error loading region'),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showCountryPicker(context, ref, user),
              ),
            ),
          ),
        ),

        // Currency Picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.currency_exchange_rounded,
                  color: AppColors.cobaltBlue),
              title: const Text('Currency'),
              subtitle: Text(_currencyLabel(currentCurrency, ref)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _showCurrencyPicker(context, ref, currentCurrency),
            ),
          ),
        ),

        // Theme Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            color: colorScheme.surface,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined,
                          color: AppColors.cobaltBlue),
                      const SizedBox(width: 16),
                      Text(
                        'Theme',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_brightness_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {currentThemeMode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(selection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.cobaltBlue
                                .withValues(alpha: 0.15);
                          }
                          return null;
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.cobaltBlue;
                          }
                          return colorScheme.onSurface;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Currency helpers ────────────────────────────────────
  String _currencyLabel(String symbol, WidgetRef ref) {
    final currenciesAsync = ref.watch(availableCurrenciesProvider);
    final currencies = currenciesAsync.value;
    if (currencies == null) return symbol;
    final match = currencies.where((c) => c.symbol == symbol);
    if (match.isNotEmpty) {
      return '${match.first.symbol}  ${match.first.code} — ${match.first.name}';
    }
    return symbol;
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, String currentSymbol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choose Currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: Consumer(
                  builder: (context, ref, child) {
                    final asyncData = ref.watch(availableCurrenciesProvider);
                    return asyncData.when(
                      data: (currencies) => ListView.builder(
                        shrinkWrap: true,
                        itemCount: currencies.length,
                        itemBuilder: (_, index) {
                          final currency = currencies[index];
                          final isSelected = currency.symbol == currentSymbol;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.cobaltBlue
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                              child: Text(
                                currency.symbol,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(currency.name),
                            subtitle: Text(currency.code),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.cobaltBlue)
                                : null,
                            onTap: () {
                              ref
                                  .read(displayCurrencyProvider.notifier)
                                  .set(currency.symbol);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(child: Text('Error: $err')),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref, User? user) {
    final currentCountry = user?.country;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Choose Region',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final asyncData = ref.watch(availableCurrenciesProvider);
                        return asyncData.when(
                          data: (countries) => ListView.builder(
                            controller: scrollController,
                            itemCount: countries.length,
                            itemBuilder: (_, index) {
                              final country = countries[index];
                              final isSelected = country.name.trim().toLowerCase() == 
                                               currentCountry?.trim().toLowerCase();

                              return ListTile(
                                leading: const Icon(Icons.public_rounded, size: 20),
                                title: Text(country.name),
                                subtitle: Text('Currency: ${country.symbol} (${country.code})'),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: AppColors.cobaltBlue)
                                    : null,
                                onTap: () async {
                                  try {
                                    Navigator.pop(ctx);
                                    // Show loading indicator
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(child: CircularProgressIndicator()),
                                    );
                                    
                                    await ref.read(userProvider.notifier).updateProfile(
                                      fullName: user?.fullName ?? '',
                                      country: country.name,
                                      currencySymbol: country.symbol,
                                    );
                                    
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close loading
                                      CustomToast.show(context: context, message: 'Region updated successfully', isError: false);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close loading
                                      CustomToast.show(context: context, message: 'Update failed: $e', isError: true);
                                    }
                                  }
                                },
                              );
                            },
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text('Error: $err')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
