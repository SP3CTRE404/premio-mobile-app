import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../services/pdf_export_service.dart';

/// Data Portability section: Export to PDF tile.
class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: colorScheme.surface,
        child: ListTile(
          leading: Icon(Icons.picture_as_pdf_rounded,
              color: AppColors.cobaltBlue),
          title: const Text('Export to PDF'),
          subtitle: const Text('Download a report of your subscriptions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _handlePdfExport(context, ref),
        ),
      ),
    );
  }

  Future<void> _handlePdfExport(BuildContext context, WidgetRef ref) async {
    final subsAsync = ref.read(subscriptionProvider);

    subsAsync.when(
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading subscriptions…')),
        );
      },
      error: (err, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $err')),
        );
      },
      data: (subscriptions) async {
        if (subscriptions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No subscriptions to export.')),
          );
          return;
        }

        try {
          final currencySymbol = ref.read(currencySymbolProvider);
          await PdfExportService.exportSubscriptions(
            subscriptions: subscriptions,
            currencySymbol: currencySymbol,
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF export failed: $e')),
            );
          }
        }
      },
    );
  }
}
