import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class Footer extends StatelessWidget {
  final VoidCallback? onAccountTap;
  const Footer({super.key, this.onAccountTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            color: AppColors.primary,
            onPressed: () {
              // Handle home button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: AppColors.primary,
            onPressed: () {
              // Handle wishlist button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            color: AppColors.primary,
            onPressed: () {
              // Handle cart button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: AppColors.primary,
            onPressed: () {
              onAccountTap?.call();
              // Handle profile button press
            },
          ),
        ],
        ),
    );
      
  }
}