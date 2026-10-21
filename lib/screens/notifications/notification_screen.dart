
import 'package:flutter/material.dart';
import 'notification_card.dart';

/// Notification centre screen listing recent in-app notifications.
///
/// Currently shows hardcoded placeholder cards. Connect to a real notification
/// source (e.g. Firestore, push payload) when the backend is ready.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Header
              Row(
                children: [
                  // Back button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Screen title and tagline
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'First to know, first to wear.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Today's notifications
              const SizedBox(height: 20),
              Text(
                'TODAY',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),

              NotificationCard(
                icon: Icons.local_shipping_outlined,
                title: 'Your order is on its way',
                description: 'Hoodie + 1 more · arriving [DATE]',
                time: '2m',
                isUnread: true,
              ),

              const SizedBox(height: 15),

              const NotificationCard(
                icon: Icons.add_business,
                title: 'New Arrivals',
                description: 'Check it now',
                time: '1hr',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
