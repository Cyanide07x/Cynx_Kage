import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Offers',
              style: TextStyle(
                color: AppColors.text,
                fontSize:26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Deals picked for you',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize:13,
              
              ),
            ),
          ],
        ),
      ),
    );
  }
}