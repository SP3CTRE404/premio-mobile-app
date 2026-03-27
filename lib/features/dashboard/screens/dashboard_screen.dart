import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

// ──────────────────────────────────────────────
// Mock data for UI development
// ──────────────────────────────────────────────

class _MockSub {
  final String name;
  final String due;
  final String price;
  final IconData icon;
  final Color statusColor;
  final double valueScore;
  final String category;

  const _MockSub({
    required this.name,
    required this.due,
    required this.price,
    required this.icon,
    required this.statusColor,
    required this.valueScore,
    required this.category,
  });
}

const _mockSubs = [
  _MockSub(
    name: 'Adobe Creative Cloud',
    due: 'Overdue by 1 day',
    price: '₹4,230',
    icon: Icons.brush,
    statusColor: Colors.redAccent,
    valueScore: 9.2,
    category: 'Productivity',
  ),
  _MockSub(
    name: 'Netflix',
    due: 'Due in 2 days',
    price: '₹649',
    icon: Icons.movie,
    statusColor: Colors.amberAccent,
    valueScore: 7.5,
    category: 'Entertainment',
  ),
  _MockSub(
    name: 'Spotify',
    due: 'Due in 3 days',
    price: '₹119',
    icon: Icons.music_note,
    statusColor: Colors.amberAccent,
    valueScore: 8.8,
    category: 'Entertainment',
  ),
  _MockSub(
    name: 'iCloud+',
    due: 'Paid',
    price: '₹75',
    icon: Icons.cloud,
    statusColor: AppColors.cobaltBlue,
    valueScore: 6.0,
    category: 'Cloud',
  ),
];

// 6-month mock spending trend
const _monthlyTrend = [3200.0, 3800.0, 4100.0, 3950.0, 4250.0, 4250.0];
const _monthLabels = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];

// Category definitions
class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

const _categories = [
  _Category('All', Icons.grid_view_rounded),
  _Category('Entertainment', Icons.movie_outlined),
  _Category('Productivity', Icons.engineering_outlined),
  _Category('Cloud', Icons.cloud_outlined),
  _Category('Finance', Icons.account_balance_outlined),
];

// Calendar due-date dots (day-of-month → color)
final _calendarDots = {
  26: Colors.redAccent,
  28: Colors.amberAccent,
  29: Colors.amberAccent,
};

// ──────────────────────────────────────────────
// Dashboard Screen
// ──────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'All';
  final Set<String> _paidItems = {};

  List<_MockSub> get _filteredSubs {
    if (_selectedCategory == 'All') return _mockSubs;
    return _mockSubs.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    const double totalSpending = 4250.00;
    const int upToDateCount = 5;
    const int dueSoonCount = 2;
    const int overdueCount = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Financial Insights Hero ──
          _buildFinancialHero(
            context,
            monthly: totalSpending,
            upToDate: upToDateCount,
            dueSoon: dueSoonCount,
            overdue: overdueCount,
          ),

          const SizedBox(height: 28),

          // ── Section 2: Category Chips ──
          _buildSectionTitle(context, 'Categories'),
          const SizedBox(height: 12),
          _buildCategoryChips(context),

          const SizedBox(height: 28),

          // ── Section 3: Action Needed with Calendar ──
          _buildSectionTitle(context, 'Action Needed'),
          const SizedBox(height: 12),
          _buildCalendarStrip(context),
          const SizedBox(height: 16),
          _buildActionCards(context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 1. FINANCIAL INSIGHTS HERO
  // ─────────────────────────────────────────

  Widget _buildFinancialHero(
    BuildContext context, {
    required double monthly,
    required int upToDate,
    required int dueSoon,
    required int overdue,
  }) {
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
                      '₹${monthly.toStringAsFixed(0)}',
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
                    // Yearly projection
                    Text(
                      '₹${yearly.toStringAsFixed(0)} / year',
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
              _buildLegendItem(context, 'Active', AppColors.cobaltBlue, upToDate),
              _buildLegendItem(context, 'Soon', Colors.amberAccent, dueSoon),
              _buildLegendItem(context, 'Overdue', Colors.redAccent, overdue),
            ],
          ),

          const SizedBox(height: 24),

          // Sparkline
          _buildSparklineSection(context),
        ],
      ),
    );
  }

  Widget _buildSparklineSection(BuildContext context) {
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
              data: _monthlyTrend,
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
            children: _monthLabels
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

  Widget _buildLegendItem(
      BuildContext context, String label, Color color, int count) {
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

  // ─────────────────────────────────────────
  // 2. CATEGORY CHIPS
  // ─────────────────────────────────────────

  Widget _buildCategoryChips(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat.label;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cobaltBlue.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cobaltBlue
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.cobaltBlue
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.cobaltBlue
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // 3. CALENDAR STRIP + ACTION CARDS
  // ─────────────────────────────────────────

  Widget _buildCalendarStrip(BuildContext context) {
    // Build the current week starting from Monday
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = days[i];
          final isToday = day.day == now.day &&
              day.month == now.month &&
              day.year == now.year;
          final dotColor = _calendarDots[day.day];

          return Column(
            children: [
              Text(
                dayNames[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.cobaltBlue
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Due-date dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor ?? Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final subs = _filteredSubs;

    if (subs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No subscriptions in this category.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Column(
      children: subs.map((sub) => _buildActionCard(context, sub)).toList(),
    );
  }

  Widget _buildActionCard(BuildContext context, _MockSub sub) {
    final isPaid = _paidItems.contains(sub.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPaid
            ? Theme.of(context).cardTheme.color?.withValues(alpha: 0.5)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isPaid ? Colors.green : sub.statusColor,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isPaid ? Colors.green : sub.statusColor)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sub.icon,
                color: isPaid ? Colors.green : sub.statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sub.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: isPaid
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      // Value Score badge
                      _buildValueBadge(sub.valueScore),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isPaid ? 'Paid ✓' : sub.due,
                          style: TextStyle(
                            color: isPaid ? Colors.green : sub.statusColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        sub.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Mark as Paid button
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isPaid) {
                    _paidItems.remove(sub.name);
                  } else {
                    _paidItems.add(sub.name);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPaid
                        ? Colors.green
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: isPaid
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueBadge(double score) {
    Color badgeColor;
    if (score >= 8.0) {
      badgeColor = Colors.greenAccent;
    } else if (score >= 6.0) {
      badgeColor = Colors.amberAccent;
    } else {
      badgeColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${score.toStringAsFixed(1)}/10',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// ──────────────────────────────────────────────
// CUSTOM PAINTERS
// ──────────────────────────────────────────────

class RingChartPainter extends CustomPainter {
  final int upToDate;
  final int dueSoon;
  final int overdue;
  final Color upToDateColor;
  final Color dueSoonColor;
  final Color overdueColor;

  RingChartPainter({
    required this.upToDate,
    required this.dueSoon,
    required this.overdue,
    required this.upToDateColor,
    required this.dueSoonColor,
    required this.overdueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = upToDate + dueSoon + overdue;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const double strokeWidth = 14.0;
    const double gapAngle = 0.1;
    double startAngle = -pi / 2;

    void drawSegment(double value, Color color) {
      if (value == 0) return;

      final sweepAngle = (value / total) * (2 * pi) - gapAngle;

      // Glow
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(rect, startAngle, sweepAngle, false, shadowPaint);

      // Solid arc
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

      startAngle += sweepAngle + gapAngle;
    }

    drawSegment(upToDate.toDouble(), upToDateColor);
    drawSegment(dueSoon.toDouble(), dueSoonColor);
    drawSegment(overdue.toDouble(), overdueColor);
  }

  @override
  bool shouldRepaint(covariant RingChartPainter oldDelegate) {
    return oldDelegate.upToDate != upToDate ||
        oldDelegate.dueSoon != dueSoon ||
        oldDelegate.overdue != overdue;
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(min) * 0.9;
    final maxVal = data.reduce(max) * 1.05;
    final range = maxVal - minVal;
    if (range == 0) return;

    final dx = size.width / (data.length - 1);

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Filled area
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth cubic bezier
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // Glow
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // End dot
    final last = points.last;
    canvas.drawCircle(
      last,
      4,
      Paint()..color = lineColor,
    );
    canvas.drawCircle(
      last,
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}