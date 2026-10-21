
import 'package:flutter/material.dart';
import '../../widgets/trending.dart';

/// Wishlist screen showing products the user has saved for later.
///
/// Products are rendered using [TrendingProductCard] in a 2-column
/// [GridView]. The back button and a share icon are shown in the header.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Placeholder wishlist data.
  final List<Map<String, String>> wishlistItems = [
    {
      'name': 'Oversized T-shirt',
      'price': 'Rs. 999',
      'image': 'assets/images/Trending_image/Trending_3.jpg',
    },
    {
      'name': 'Cargo Pants',
      'price': 'Rs. 1,499',
      'image': 'assets/images/Trending_image/Trending_4.jpg',
    },
    {
      'name': 'Straight Jeans',
      'price': 'Rs. 999',
      'image': 'assets/images/Trending_image/Trending_5.jpg',
    },
    {
      'name': 'Jackets',
      'price': 'Rs. 2,999',
      'image': 'assets/images/Trending_image/Trending_6.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Header
              Row(
                children: [
                  // Back button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Title and item count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wishlist',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wishlistItems.length} saved pieces',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Share button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: Icon(
                        Icons.ios_share,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Product grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: wishlistItems.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final product = wishlistItems[index];

                    return TrendingProductCard(
                      name: product['name']!,
                      price: product['price']!,
                      imageAsset: product['image']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
