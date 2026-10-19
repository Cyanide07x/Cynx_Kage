// ─────────────────────────────────────────────────────────────────────────────
// screens/account/account_action_button.dart
// Reusable tappable list row used in the Account screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';

/// A full-width tappable tile that combines an icon, a label, and a trailing
/// chevron arrow - used for account actions such as "My Orders" or "Log out".
///
/// The "Log out" tile automatically renders its label in [AppColors.error]
/// (red) to signal a destructive action.
class AccountActionButton extends StatelessWidget {
  /// Material icon shown on the left side of the tile.
  final IconData icon;

  /// Text label displayed in the centre of the tile.
  final String title;

  /// Callback invoked when the tile is tapped.
  final VoidCallback onTap;

  const AccountActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // ── Icon container ───────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.deepForest,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // ── Label ──────────────────────────────────────────────────
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  // "Log out" is shown in red to indicate a destructive action.
                  color: title == 'Log out'
                      ? AppColors.error
                      : AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Trailing chevron ────────────────────────────────────────
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
