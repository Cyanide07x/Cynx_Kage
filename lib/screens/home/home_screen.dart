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
              child: CustomScrollView(
                slivers: [
                  // Hero section
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Sticky Search Bar + Categories
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickySearchDelegate(),
                  ),

                  // New Arrivals
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: NewArrivals(),
                    ),
                  ),

                  // Trending
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Trending(),
                    ),
                  ),
                ],
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


// ============================================================
// STICKY SEARCH + CATEGORY HEADER
// ============================================================

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 115;

  @override
  double get maxExtent => 115;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.appBackground,
      child: Column(
        children: [
          const SizedBox(height: 5),

          // Search Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedSearchBar(
              hint: 'Search jackets, cargos',
            ),
          ),

          const SizedBox(height: 15),

          // Category Buttons
          SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    // All
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

                    // Men
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

                    // Women
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

                    // Kids
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

                    // Unisex
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

                    const SizedBox(width: 15),

                    // Streetwear
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

                    // Accessories
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
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant SliverPersistentHeaderDelegate oldDelegate,
  ) {
    return false;
  }
}