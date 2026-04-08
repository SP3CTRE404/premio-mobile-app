import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../services/pdf_export_service.dart';
import '../../../core/widgets/custom_toast.dart';

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
        CustomToast.show(context: context, message: 'Loading subscriptions…', isError: false);
      },
      error: (err, _) {
        CustomToast.show(context: context, message: 'Error: $err', isError: true);
      },
      data: (subscriptions) async {
        if (subscriptions.isEmpty) {
          CustomToast.show(context: context, message: 'No subscriptions to export.', isError: false);
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
            CustomToast.show(context: context, message: 'PDF export failed: $e', isError: false);
          }
        }
      },
    );
  }
}
