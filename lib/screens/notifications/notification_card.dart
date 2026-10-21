
import 'package:flutter/material.dart';

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

  /// When `true`, a small accent dot is rendered below the timestamp.
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
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(
            color: colors.outlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.outlineVariant,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colors.primary,
                size: 19,
              ),
            ),

            const SizedBox(width: 10),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Timestamp and unread dot
            Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.primary,
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
