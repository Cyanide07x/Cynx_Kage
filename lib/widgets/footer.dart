import 'package:flutter/material.dart';
import '../theme/appcolors.dart';
import '../screens/account/account_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/home/home_screen.dart';

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
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=> const HomeScreen(),
              ),
              );
              // Handle home button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: AppColors.primary,
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context)=> const WishlistScreen(),
              ),
              );
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
              Navigator.push(context,
              MaterialPageRoute(builder: (context)=> const AccountScreen(),
               ),
               );
              // Handle profile button press
            },
          ),
        ],
        ),
    );
      
  }
}