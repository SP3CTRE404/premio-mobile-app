import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';

/// Look & Feel section: currency picker + theme toggle.
class LookAndFeelSection extends ConsumerWidget {
  const LookAndFeelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentCurrency = ref.watch(currencySymbolProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Currency Picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: colorScheme.surface,
            child: ListTile(
              leading: Icon(Icons.currency_exchange_rounded,
                  color: AppColors.cobaltBlue),
              title: const Text('Currency'),
              subtitle: Text(_currencyLabel(currentCurrency)),
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
                      Icon(Icons.palette_outlined,
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
  String _currencyLabel(String symbol) {
    final match = availableCurrencies.where((c) => c.symbol == symbol);
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
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableCurrencies.length,
                  itemBuilder: (_, index) {
                    final currency = availableCurrencies[index];
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
                            .read(currencySymbolProvider.notifier)
                            .set(currency.symbol);
                        Navigator.pop(ctx);
                      },
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
}
