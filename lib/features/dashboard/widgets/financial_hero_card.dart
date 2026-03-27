import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import 'ring_chart_painter.dart';

/// The hero card showing monthly/yearly spend and ring chart.
class FinancialHeroCard extends StatelessWidget {
  final double monthly;
  final int upToDate;
  final int dueSoon;
  final int overdue;
  final String currencySymbol;

  const FinancialHeroCard({
    super.key,
    required this.monthly,
    required this.upToDate,
    required this.dueSoon,
    required this.overdue,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final yearly = monthly * 12;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Ring chart with center text
          SizedBox(
            height: 190,
            width: 190,
            child: CustomPaint(
              painter: RingChartPainter(
                upToDate: upToDate,
                dueSoon: dueSoon,
                overdue: overdue,
                upToDateColor: AppColors.cobaltBlue,
                dueSoonColor: Colors.amberAccent,
                overdueColor: Colors.redAccent,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatCurrency(monthly, currencySymbol),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/ month',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatCurrency(yearly, currencySymbol)} / year',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(label: 'Active', color: AppColors.cobaltBlue, count: upToDate),
              _LegendItem(label: 'Upcoming', color: Colors.amberAccent, count: dueSoon),
              _LegendItem(label: 'Overdue', color: Colors.redAccent, count: overdue),
            ],
          ),
          
          // Removed the SparklineSection from here
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final int count;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ], 
    );
  }
}