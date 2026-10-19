// ─────────────────────────────────────────────────────────────────────────────
// screens/notifications/notification_card.dart
// Individual notification row widget used in [NotificationScreen].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../theme/appcolors.dart';

/// Displays a single notification entry with an icon, title, description,
/// timestamp, and an optional unread indicator dot.
///
/// ```dart
/// NotificationCard(
///   icon: Icons.local_shipping_outlined,
///   title: 'Your order is on its way',
///   description: 'Hoodie + 1 more arriving tomorrow',
///   time: '2m',
///   isUnread: true,
/// )
/// ```
class NotificationCard extends StatelessWidget {
  /// Material icon representing the notification type (e.g. shipping, offers).
  final IconData icon;

  /// Short, bold title line of the notification.
  final String title;

  /// Supporting detail text (one or two lines).
  final String description;

  /// Human-readable timestamp shown in the trailing column (e.g. '2m', '1hr').
  final String time;

  /// When `true`, a small lime dot is rendered below the timestamp to indicate
  /// that this notification has not been read.
  final bool isUnread;

  /// Optional tap handler. The card is tappable only when this is non-null.
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.appBackground,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon badge ──────────────────────────────────────────────
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 19,
              ),
            ),

            const SizedBox(width: 10),

            // ── Title and description ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Timestamp and unread dot ──────────────────────────────
            Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  // Small lime circle = unread indicator.
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}