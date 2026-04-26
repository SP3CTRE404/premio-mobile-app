import 'dart:math';
import 'package:flutter/material.dart';

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
