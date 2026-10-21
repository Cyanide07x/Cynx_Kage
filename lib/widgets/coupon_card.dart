
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Displays a promotional coupon with a discount amount, description, coupon
/// code, and a "Copy" button that copies [code] to the clipboard.
class CouponCard extends StatelessWidget {
  final String discount;
  final String description;
  final String code;

  const CouponCard({
    super.key,
    required this.discount,
    required this.description,
    required this.code,
  });

  /// Copies [code] to the system clipboard and shows a confirmation [SnackBar].
  Future<void> _copyCoupon(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));

    if (!context.mounted) return;

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon $code copied'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Discount amount
          SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  discount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'OFF',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            height: 48,
            color: colors.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // Description and code
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  code,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Copy button
          OutlinedButton(
            onPressed: () => _copyCoupon(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onSurface,
              side: BorderSide(color: colors.outlineVariant),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Copy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
