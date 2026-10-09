import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/appcolors.dart';
import '../../widgets/header.dart';
import '../../widgets/searchbar.dart';
import '../../widgets/new_arrivals.dart';
import '../../Widgets/trending.dart';
import 'men.dart';
import 'women.dart';

class HomeScreen extends StatefulWidget {
  final bool showNavigation;

  const HomeScreen({
    super.key,
    this.showNavigation = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showNavigation) const Header(),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Hero section
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
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
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),

                  // Sticky Search Bar + Categories
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickySearchDelegate(
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  ),

                  // Body content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: _buildCategoryBody(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildCategoryBody() {
    // Men's Collection
    if (selectedCategory == 'Men') {
      return const MenScreen();
    }

    // Women's Collection
    if (selectedCategory == 'Women') {
      return const WomenScreen();
    }

    // Original homepage
    if (selectedCategory == 'All') {
      return const Column(
        children: [
          NewArrivals(),
          SizedBox(height: 30),
          Trending(),
          SizedBox(height: 30),
        ],
      );
    }

    // Other categories
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      child: Center(
        child: Text(
          '$selectedCategory collection coming soon',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STICKY SEARCH + CATEGORY HEADER
// ============================================================

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  _StickySearchDelegate({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  // Increased height to reserve permanent space beneath categories.
  @override
  double get minExtent => 123;

  @override
  double get maxExtent => 123;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    const categories = [
      'All',
      'Men',
      'Women',
      'Kids',
      'Unisex',
      'Streetwear',
      'Accessories',
    ];

    return Container(
      color: AppColors.appBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),

          // Search Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedSearchBar(
              hint: 'Search jackets, cargos',
            ),
          ),

          const SizedBox(height: 20),

          // Selectable Category Buttons
          SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    for (int i = 0; i < categories.length; i++) ...[
                      if (i > 0) const SizedBox(width: 15),
                      _buildCategoryButton(categories[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Permanent gap below the categories.
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = selectedCategory == category;

    final widths = <String, double>{
      'All': 60,
      'Men': 60,
      'Women': 80,
      'Kids': 60,
      'Unisex': 80,
      'Streetwear': 110,
      'Accessories': 120,
    };

    return InkWell(
      onTap: () => onCategorySelected(category),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: widths[category],
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    AppColors.border,
                    AppColors.deepForest,
                  ]
                : [
                    AppColors.surface,
                    AppColors.appBackground,
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          category,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant _StickySearchDelegate oldDelegate,
  ) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}