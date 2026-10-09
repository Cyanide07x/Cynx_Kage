
import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class Header extends StatelessWidget {
  final VoidCallback? onNotificationTap;
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