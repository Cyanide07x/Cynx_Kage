
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/theme_controller.dart';
import '../../theme/apptheme.dart';
import '../../widgets/header.dart';
import '../../widgets/searchbar.dart';
import '../../widgets/new_arrivals.dart';
import '../../Widgets/trending.dart';
import '../../widgets/product_search_results.dart';
import 'men.dart';
import 'women.dart';
import 'unisex.dart';

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
  String _searchQuery = '';

  late Future<String> _heroSvgFuture;

  @override
  void initState() {
    super.initState();
    _heroSvgFuture = rootBundle.loadString(
      'assets/images/Herotag.svg',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final isCynx =
            themeController.selectedTheme == CynxThemeMode.cynx;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                child: FutureBuilder<String>(
                                  future: _heroSvgFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    final themedSvg = snapshot.data!
                                        .replaceAll(
                                          '#BBD58E',
                                          isCynx
                                              ? '#E50046'
                                              : '#BBD58E',
                                        )
                                        .replaceAll(
                                          '#bbd58e',
                                          isCynx
                                              ? '#FF2D9A'
                                              : '#bbd58e',
                                        );

                                    return SvgPicture.string(
                                      themedSvg,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.centerLeft,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),

                      // Sticky search bar and categories
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickySearchDelegate(
                          selectedCategory: selectedCategory,
                          searchQuery: _searchQuery,
                          onSearchChanged: (query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                          onCategorySelected: (category) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      ),

                      // Main content or search results
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
      },
    );
  }

  Widget _buildCategoryBody() {
    // Show search results while the user has entered a query.
    if (_searchQuery.trim().isNotEmpty) {
  return ProductSearchResults(
    query: _searchQuery.trim(),
    selectedCategory: selectedCategory,
  );
}

    if (selectedCategory == 'Men') {
      return const MenScreen();
    }

    if (selectedCategory == 'Women') {
      return const WomenScreen();
    }

    if (selectedCategory == 'Unisex') {
      return const UnisexScreen();
    }

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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      child: Center(
        child: Text(
          '$selectedCategory collection coming soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  _StickySearchDelegate({
    required this.selectedCategory,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

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
      'Unisex',
      'Streetwear',
      'Accessories',
    ];

    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedSearchBar(
              hint: 'Search jackets, cargos',
              onChanged: onSearchChanged,
            ),
          ),

          const SizedBox(height: 20),

          // Selectable category buttons
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
                      _buildCategoryButton(
                        categories[i],
                        colors,
                        theme,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    String category,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final isSelected = selectedCategory == category;

    final widths = <String, double>{
      'All': 60,
      'Men': 60,
      'Women': 80,
      'Unisex': 80,
      'Streetwear': 110,
      'Accessories': 120,
    };

    return InkWell(
      onTap: () => onCategorySelected(category),
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: widths[category],
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    colors.surfaceContainerHighest,
                    colors.surface,
                  ]
                : [
                    colors.surface,
                    theme.scaffoldBackgroundColor,
                  ],
          ),
          border: Border.all(
            color: isSelected ? colors.primary : theme.dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          category,
          style: TextStyle(
            color: isSelected
                ? colors.onSurface
                : colors.onSurfaceVariant,
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
    return oldDelegate.selectedCategory != selectedCategory ||
        oldDelegate.searchQuery != searchQuery;
  }
}
