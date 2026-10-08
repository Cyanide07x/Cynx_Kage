import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/appcolors.dart';
import '../../widgets/footer.dart';
import '../../widgets/header.dart';
import '../../widgets/searchbar.dart';
import '../../widgets/new_arrivals.dart';
import '../../Widgets/trending.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,

      body: SafeArea(
        child: Column(
          children: [
            const Header(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Hero
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: SvgPicture.asset(
                          'assets/images/Herotag.svg',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),

                    // Space between Hero and Search Bar
                    const SizedBox(height: 20),

                    // Search Bar
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: AnimatedSearchBar(
                        hint: 'Search jackets, cargos',
                      ),
                    ),

                    // Space between Search Bar and Buttons
                    const SizedBox(height: 20),

                    // Category Buttons
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'All',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Men',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15), 
                              Container(
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Women',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Kids',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Unisex',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width:15),
                              Container(
                                width: 110,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Streetwear',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 120,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.deepForest,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Accessories',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const NewArrivals(),

                    const SizedBox(height:30),

                    const Trending(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Footer(
          onAccountTap: () {
            // Account will be added later
          },
        ),
      ),
    );
  }
}