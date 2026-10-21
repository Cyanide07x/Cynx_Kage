
import 'package:flutter/material.dart';

/// A small outlined button that acts as a filter chip on the Offers screen.
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
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        backgroundColor: isSelected
            ? colors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outlineVariant,
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
