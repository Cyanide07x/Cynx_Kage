import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import 'notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.only(left: 5, right:20),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            
Row(
  children: [
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
          if (Navigator.of(context).canPop()){
                          Navigator.of(context).pop();
                        }
          // Back button action
        },
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.text,
          size: 20,
        ),
      ),
    ),
    const SizedBox(width: 20),
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

const SizedBox(height: 20),
Text('TODAY'),

const SizedBox(height: 15),

NotificationCard(
  icon: Icons.local_shipping_outlined,
  title: 'Your order is on its way',
  description: 'Hoodie + 1 more · arriving [DATE]',
  time: '2m',
  isUnread: true,
),

const SizedBox(height: 15),

NotificationCard(icon: Icons.add_business, title: 'New Arrivals', description: 'Check it now', time: '1hr')
          ],
        ),
      ),
      ),
    );
  }
}