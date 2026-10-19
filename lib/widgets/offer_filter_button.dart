// ─────────────────────────────────────────────────────────────────────────────
// widgets/offer_filter_button.dart
// Compact toggle chip used to filter offers by type.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

/// A small outlined button that acts as a filter chip on the Offers screen.
///
/// When [isSelected] is `true` the button renders with a lime border and a
/// dark-green background to indicate the active filter.
class OfferFilterButton extends StatelessWidget {
  /// The filter label displayed on the button (e.g. 'All', 'Coupons').
  final String title;

  /// Whether this filter is the currently active one.
  final bool isSelected;

  /// Callback invoked when the button is tapped.
  final VoidCallback onTap;

  const OfferFilterButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        // Active chip gets a subtle dark-green fill.
        backgroundColor: isSelected
            ? const Color(0xFF202719)
            : Colors.transparent,
        side: BorderSide(
          color: isSelected
              ? const Color(0xFFC5E37A) // lime border when active
              : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
