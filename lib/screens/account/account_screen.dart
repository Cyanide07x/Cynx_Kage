import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import 'tracker.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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

              // Existing Account header — unchanged
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
                          'Account',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your gear, your rules.',
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

              // Space between header and profile
              const SizedBox(height: 32),

              // Profile row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'US',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Name and email
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Utsav Sachan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'utsav0724@gmail.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Edit profile button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit profile',
                      onPressed: () {
                        // Connect the edit profile screen later.
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

Row(
  children: [
    const Expanded(
      child: Tracker(
        count: '00',
        title: 'Orders',
      ),
    ),
    const SizedBox(width: 10),
    const Expanded(
      child: Tracker(
        count: '00',
        title: 'Wishlist',
      ),
    ),
    const SizedBox(width: 10),
    const Expanded(
      child: Tracker(
        count: '03',
        title: 'Coupons',
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