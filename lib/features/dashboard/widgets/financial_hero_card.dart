import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/mock_data.dart';
import 'ring_chart_painter.dart';
import 'sparkline_painter.dart';

/// The hero card showing monthly/yearly spend, ring chart, and sparkline.
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

          const SizedBox(height: 24),

          // Sparkline
          _SparklineSection(),
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

class _SparklineSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.06),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(width: 8),
            Text(
              '6-Month Trend',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            Text(
              '+3.2%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.cobaltBlue.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: CustomPaint(
            size: const Size(double.infinity, 48),
            painter: SparklinePainter(
              data: monthlyTrend,
              lineColor: AppColors.cobaltBlue,
              fillColor: AppColors.cobaltBlue.withValues(alpha: 0.08),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Month labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthLabels
                .map((m) => Text(
                      m,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
