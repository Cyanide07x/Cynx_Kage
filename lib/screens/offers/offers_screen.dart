import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

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
            'Offers',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Deals picked for you',
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

          ],
        ),
      ),
      ),
    );
  }
}