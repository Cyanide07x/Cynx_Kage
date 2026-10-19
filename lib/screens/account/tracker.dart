// ─────────────────────────────────────────────────────────────────────────────
// screens/account/tracker.dart
// Compact stat tile shown in the Account screen header row.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';

/// A small card that displays a numeric stat (e.g. orders, wishlist count).
///
/// Used in the Account screen to give users a quick summary of their activity.
///
/// ```dart
/// Tracker(count: '03', title: 'Orders')
/// ```
class Tracker extends StatelessWidget {
  /// The numeric value to display (passed as a pre-formatted string, e.g. '03').
  final String count;

  /// Label describing the stat (e.g. 'Orders', 'Wishlist', 'Coupons').
  final String title;

  const Tracker({
    super.key,
    required this.count,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lime count - intentionally large to stand out.
          Text(
            count,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle label - clipped to one line with ellipsis.
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}