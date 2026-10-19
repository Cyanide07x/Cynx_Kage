// ─────────────────────────────────────────────────────────────────────────────
// widgets/header.dart
// App-wide top header bar shown inside [NavigationShell].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

/// Persistent top bar displayed at the top of [NavigationShell].
///
/// Contains:
/// - The "CYNX KAGE" wordmark on the left.
/// - A notification bell icon on the right.
/// - A shopping-bag icon on the right.
///
/// Both icon buttons are optional; pass a callback to make them interactive.
class Header extends StatelessWidget {
  /// Called when the notification bell icon is tapped.
  /// If `null`, the icon is still shown but does nothing.
  final VoidCallback? onNotificationTap;

  /// Called when the shopping-bag icon is tapped.
  /// If `null`, the icon is still shown but does nothing.
  final VoidCallback? onCartTap;

  const Header({
    super.key,
    this.onNotificationTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // ── Brand wordmark ────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'CYNX KAGE',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          const Spacer(),

          // ── Action icons ──────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textSecondary,
            onPressed: onNotificationTap,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color: AppColors.textSecondary,
            onPressed: onCartTap,
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}