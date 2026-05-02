import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// The hero card designed to match the sleek, neon-glowing
/// analytics aesthetic, now fully theme-aware for light and dark modes.
class FinancialHeroCard extends StatelessWidget {
  final double monthly;
  final int upToDate;
  final int dueSoon;
  final int overdue;
  final String currencySymbol;
  final bool isAdmin;
  final int personalCount;
  final int householdCount;

  const FinancialHeroCard({
    super.key,
    required this.monthly,
    required this.upToDate,
    required this.dueSoon,
    required this.overdue,
    required this.currencySymbol,
    this.isAdmin = false,
    this.personalCount = 0,
    this.householdCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final yearly = monthly * 12;
    final totalSubs = upToDate + dueSoon + overdue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors from AppColors
    final cardBackground = isDark ? AppColors.darkSurface : AppColors.pureWhite;
    final trackColor = isDark ? AppColors.white06 : AppColors.black04;
    final textMuted = isDark
        ? AppColors.onSurfaceDark50
        : AppColors.onSurfaceLight50;
    final textPrimary = isDark ? Colors.white : Colors.black87;

    // Neon palette for the data
    final neonCyan = AppColors.cobaltBlue;
    const neonAmber = Color(0xFFFFB800);
    const neonRed = Color(0xFFFF3366);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left Column: Typography & Pill ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Spend',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(monthly, currencySymbol),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // The small pill mimicking the "+12.4%" badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Est. ${formatCurrency(yearly, currencySymbol)} / yr',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right Column: Glowing Ring Chart ──
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: _NeonRingPainter(
                        upToDate: upToDate,
                        dueSoon: dueSoon,
                        overdue: overdue,
                        trackColor: trackColor,
                        upToDateColor: neonCyan,
                        dueSoonColor: neonAmber,
                        overdueColor: neonRed,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totalSubs.toString(),
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Subs',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 0),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TinyBreakdownItem(
                            icon: Icons.person_rounded,
                            count: personalCount,
                            color: textMuted,
                          ),
                          const SizedBox(width: 8),
                          _TinyBreakdownItem(
                            icon: Icons.home_rounded,
                            count: householdCount,
                            color: textMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Bottom Row: Stats Legend ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.03,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Upcoming',
                  count: dueSoon,
                  color: neonAmber,
                  textColor: textMuted,
                  countColor: textPrimary,
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                _StatItem(
                  label: 'Overdue',
                  count: overdue,
                  color: neonRed,
                  textColor: textMuted,
                  countColor: textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom stat item mimicking the dot-and-text layout
class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color textColor;
  final Color countColor;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: TextStyle(
            color: countColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw the thick, glowing neon ring chart as a 270-degree arc
class _NeonRingPainter extends CustomPainter {
  final int upToDate;
  final int dueSoon;
  final int overdue;
  final Color trackColor;
  final Color upToDateColor;
  final Color dueSoonColor;
  final Color overdueColor;

  _NeonRingPainter({
    required this.upToDate,
    required this.dueSoon,
    required this.overdue,
    required this.trackColor,
    required this.upToDateColor,
    required this.dueSoonColor,
    required this.overdueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = upToDate + dueSoon + overdue;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;
    const strokeWidth = 12.0;

    // We want a 270-degree arc (3/4 circle)
    const totalSweep = pi * 1.3;
    const startAngle = pi * 0.85; // Starts at bottom-left (7:30 position)
    const gap = 0.12; // Gap between segments in radians

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background track arc
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, totalSweep, false, bgPaint);

    if (total == 0) return;

    double currentAngle = startAngle;

    void drawSegment(int count, Color color) {
      if (count == 0) return;

      // Calculate this segment's portion of the 270-degree sweep
      final segmentSweep = (count / total) * totalSweep;
      final actualSweep = max(0.05, segmentSweep - gap);

      // 1. Draw the Glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        rect,
        currentAngle + (gap / 2),
        actualSweep,
        false,
        glowPaint,
      );

      // 2. Draw the solid core line
      final solidPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        currentAngle + (gap / 2),
        actualSweep,
        false,
        solidPaint,
      );

      currentAngle += segmentSweep;
    }

    // Draw segments in order
    drawSegment(upToDate, upToDateColor);
    drawSegment(dueSoon, dueSoonColor);
    drawSegment(overdue, overdueColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TinyBreakdownItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _TinyBreakdownItem({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
