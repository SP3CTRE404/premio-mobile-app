import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../subscriptions/models/subscription_model.dart';

/// Service responsible for generating and sharing a PDF subscription report.
/// Isolated from the UI layer per the "Service Layer Isolation" rule.
class PdfExportService {
  /// Generates a PDF report from the given [subscriptions] list and opens
  /// the system share/save dialog.
  static Future<void> exportSubscriptions({
    required List<Subscription> subscriptions,
    required String currencySymbol,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final dateString =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── Header ──
          pw.Center(
            child: pw.Text(
              'SubTrack — Subscription Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'Generated on $dateString',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.SizedBox(height: 24),

          // ── Table ──
          if (subscriptions.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 40),
                child: pw.Text(
                  'No subscriptions to display.',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey100,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              headers: ['Service Name', 'Price', 'Billing Cycle'],
              data: subscriptions.map((sub) {
                return [
                  sub.serviceName,
                  '$currencySymbol${sub.amount.toStringAsFixed(2)}',
                  _formatCycle(sub.billingCycle),
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 24),

          // ── Summary ──
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Subscriptions: ${subscriptions.length}',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total: $currencySymbol${subscriptions.fold<double>(0, (sum, s) => sum + s.amount).toStringAsFixed(2)}',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'subtrack_report_$dateString.pdf',
    );
  }

  static String _formatCycle(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.MONTHLY:
        return 'Monthly';
      case BillingCycle.QUARTERLY:
        return 'Quarterly';
      case BillingCycle.YEARLY:
        return 'Yearly';
    }
  }
}
