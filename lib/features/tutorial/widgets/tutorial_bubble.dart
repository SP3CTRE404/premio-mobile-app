import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ArrowDirection { up, down }

class TutorialBubble extends StatelessWidget {
  final String title;
  final String description;
  final ArrowDirection arrowDirection;
  final double pointerX;
  final double width;
  final String buttonLabel;
  final VoidCallback onDismiss;
  final VoidCallback onSkipAll;

  const TutorialBubble({
    super.key,
    required this.title,
    required this.description,
    required this.arrowDirection,
    required this.pointerX,
    required this.width,
    this.buttonLabel = 'Got it!',
    required this.onDismiss,
    required this.onSkipAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arrowDirection == ArrowDirection.up) ...[
            // Thought bubbles pointing up to target above
            Padding(
              padding: EdgeInsets.only(left: pointerX - 3),
              child: _buildSmallBubble(context, 6, 0.35),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: pointerX - 5),
              child: _buildSmallBubble(context, 10, 0.65),
            ),
            const SizedBox(height: 7),
          ],
          // Main Glassmorphic Cloud Card
          _buildMainCard(context, isDark, theme),
          if (arrowDirection == ArrowDirection.down) ...[
            // Thought bubbles pointing down to target below
            const SizedBox(height: 7),
            Padding(
              padding: EdgeInsets.only(left: pointerX - 5),
              child: _buildSmallBubble(context, 10, 0.65),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: pointerX - 3),
              child: _buildSmallBubble(context, 6, 0.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallBubble(BuildContext context, double size, double opacity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? AppColors.cobaltBlue.withValues(alpha: opacity * 0.8)
            : AppColors.cobaltBlue.withValues(alpha: opacity * 0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.cobaltBlue.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.cobaltBlue.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.colorScheme.surface.withValues(alpha: 0.88),
                        theme.colorScheme.surface.withValues(alpha: 0.75),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.94),
                        Colors.white.withValues(alpha: 0.86),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.cobaltBlue.withValues(alpha: 0.3)
                    : AppColors.cobaltBlue.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wb_cloudy_rounded,
                        size: 18,
                        color: AppColors.cobaltBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: isDark ? 0.8 : 0.7,
                    ),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onSkipAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Skip Tour',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cobaltBlue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.cobaltBlue.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
