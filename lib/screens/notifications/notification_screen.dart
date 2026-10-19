// ─────────────────────────────────────────────────────────────────────────────
// screens/notifications/notification_screen.dart
// Full-screen notification centre pushed from [NavigationShell].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import 'notification_card.dart';

/// Notification centre screen listing recent in-app notifications.
///
/// Currently shows hardcoded placeholder cards. Connect to a real notification
/// source (e.g. Firestore, push payload) when the backend is ready.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  // Back button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Screen title and tagline
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'First to know, first to wear.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Today's notifications ─────────────────────────────────
              const SizedBox(height: 20),
              const Text(
                'TODAY',
                style: TextStyle(
                  color: AppColors.textSecondary,
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