
import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../widgets/searchbar.dart';

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
                      onPressed: () => Navigator.of(context).maybePop(),
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

              const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: AnimatedSearchBar(
    hint: 'Search for answers',
    height: 46,
  ),
),
              
              
            ],
          ),
        ),
      ),
    );
  }
}
