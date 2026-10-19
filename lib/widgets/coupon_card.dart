// ─────────────────────────────────────────────────────────────────────────────
// widgets/coupon_card.dart
// Coupon tile shown in the Offers screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/appcolors.dart';

/// Displays a promotional coupon with a discount amount, description, coupon
/// code, and a "Copy" button that copies [code] to the clipboard.
///
/// ```dart
/// CouponCard(
///   discount: '20%',
///   description: 'On your first order',
///   code: 'FIRST20',
/// )
/// ```
class CouponCard extends StatelessWidget {
  /// The discount value displayed prominently (e.g. '20%', 'B2G1').
  final String discount;

  /// A short description of the coupon's terms.
  final String description;

  /// The coupon code that is copied to the clipboard on tap.
  final String code;

  const CouponCard({
    super.key,
    required this.discount,
    required this.description,
    required this.code,
  });

  // ── Actions ────────────────────────────────────────────────────────────

  /// Copies [code] to the system clipboard and shows a confirmation [SnackBar].
  Future<void> _copyCoupon(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon $code copied'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ── Discount amount ───────────────────────────────────────────
          SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  discount,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'OFF',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // ── Vertical divider ──────────────────────────────────────────
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // ── Description and code ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  code,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Copy button ─────────────────────────────────────────────
          OutlinedButton(
            onPressed: () => _copyCoupon(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.border),
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
