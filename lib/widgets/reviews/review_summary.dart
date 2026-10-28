import 'package:flutter/material.dart';
import 'review_model.dart';

class ReviewSummary extends StatelessWidget {
  final ProductRatingSummary summary;

  const ReviewSummary({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Score + Stars + Total Count
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large rating number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        summary.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ 5.0',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Star icons row
                  _buildStars(summary.averageRating, colors),
                  const SizedBox(height: 6),
                  Text(
                    '${summary.totalReviews} verified reviews',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Rating distribution bars (5 to 1 star)
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final percent = summary.getPercentage(star);
                    final count = summary.starDistribution[star] ?? 0;
                    return _buildDistributionRow(
                      context,
                      star: star,
                      percent: percent,
                      count: count,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStars(double rating, ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFFFB800), // Rich amber gold
          ),
        );
      }),
    );
  }

  Widget _buildDistributionRow(
    BuildContext context, {
    required int star,
    required double percent,
    required int count,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          // Star label
          SizedBox(
            width: 14,
            child: Text(
              '$star',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.star_rounded,
            size: 11,
            color: Color(0xFFFFB800),
          ),
          const SizedBox(width: 8),

          // Progress Bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: colors.outlineVariant.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(
                  star >= 4 ? colors.primary : colors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Count
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
