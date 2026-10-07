import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
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
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            const Spacer(),

            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.primary,
              onPressed: () {},
            ),

            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              color: AppColors.primary,
              onPressed: () {},
            ),

            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}