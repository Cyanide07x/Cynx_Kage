
import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../widgets/searchbar.dart';
import 'account_action_button.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help & Support',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "We've got your back.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),
              Padding(
  padding: EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'How can we\nhelp you?',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
      SizedBox(height: 10),
      Text(
        'Find answers or talk to our team.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSearchBar(
                  hint: 'Search for answers',
                  height: 46,
                ),
              ),

              const SizedBox(height: 25),

              Text(
        ' Browse topics',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),

      const SizedBox(height: 20),

AccountActionButton(
  icon: Icons.inventory_2_outlined,
  title: 'Orders & delivery',
  onTap: () {},
),
const SizedBox(height: 15),

AccountActionButton(
  icon: Icons.swap_horiz_rounded,
  title: 'Returns & refunds',
  onTap: () {},
),
const SizedBox(height: 15),

AccountActionButton(
  icon: Icons.credit_card_outlined,
  title: 'Payments',
  onTap: () {},
),
const SizedBox(height: 15),

AccountActionButton(
  icon: Icons.straighten_rounded,
  title: 'Size & fit',
  onTap: () {},
),

      
              
            ],
          ),
        ),
      ),
    );
  }
}
