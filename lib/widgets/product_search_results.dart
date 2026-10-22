
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'trending.dart';

class ProductSearchResults extends StatelessWidget {
  final String query;
  final String selectedCategory;

  const ProductSearchResults({
    super.key,
    required this.query,
    required this.selectedCategory,
  });

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _expandSynonyms(String value) {
    return ' $value '
        .replaceAll(RegExp(r'\bt shirts?\b'), ' tshirt ')
        .replaceAll(RegExp(r'\btshirts?\b'), ' tshirt ')
        .replaceAll(RegExp(r'\btees?\b'), ' tshirt ')
        .replaceAll(RegExp(r'\bhoodies?\b'), ' hoodie ')
        .replaceAll(RegExp(r'\bjeans?\b'), ' denim ')
        .replaceAll(RegExp(r'\btrousers?\b'), ' pants ')
        .replaceAll(RegExp(r'\bcargos?\b'), ' cargo ');
  }

  bool _matches(
    Map<String, dynamic> product,
    String searchQuery,
  ) {
    final normalizedQuery = _expandSynonyms(
      _normalize(searchQuery),
    ).trim();

    if (normalizedQuery.isEmpty) return true;

    String readField(String key) =>
        (product[key] ?? '').toString();

    final name = _normalize(readField('name'));
    final description = _normalize(readField('description'));

    final productType = _normalize([
      product['clothingType'],
      product['productType'],
      product['designCategory'],
      product['productGroup'],
      product['designName'],
    ].where((value) => value != null).join(' '));

    final primaryText = _expandSynonyms(
      _normalize('$name $productType'),
    );

    final category = _normalize(readField('category'));

    const categoryAliases = <String, String>{
      'men': 'men',
      'mens': 'men',
      'man': 'men',
      'male': 'men',
      'women': 'women',
      'womens': 'women',
      'woman': 'women',
      'female': 'women',
      'unisex': 'unisex',
    };

    final queryWords = normalizedQuery
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    final requestedCategories = queryWords
        .where(categoryAliases.containsKey)
        .map((word) => categoryAliases[word]!)
        .toSet();

    if (requestedCategories.isNotEmpty &&
        !requestedCategories.contains(category)) {
      return false;
    }

    const categoryWords = {
      'men',
      'mens',
      'man',
      'male',
      'women',
      'womens',
      'woman',
      'female',
      'unisex',
    };

    final searchWords = queryWords
        .where((word) => !categoryWords.contains(word))
        .toList();

    if (searchWords.isEmpty) {
      return true;
    }

    final wantsHoodie = searchWords.contains('hoodie');
    final wantsDenim = searchWords.contains('denim');
    final wantsTshirt = searchWords.contains('tshirt');
    final wantsCargo = searchWords.contains('cargo');
    final wantsPants = searchWords.contains('pants');

    final requestedTypes = [
      wantsHoodie,
      wantsDenim,
      wantsTshirt,
      wantsCargo,
      wantsPants,
    ].where((matches) => matches).length;

    if (requestedTypes > 1) return false;

    // A specific clothing type must match the product name
    // or structured product-type fields, not just its description.
    if (wantsHoodie && !primaryText.contains('hoodie')) {
      return false;
    }

    if (wantsDenim &&
        !RegExp(r'\bdenim\b').hasMatch(primaryText)) {
      return false;
    }

    if (wantsTshirt && !primaryText.contains('tshirt')) {
      return false;
    }

    if (wantsCargo && !primaryText.contains('cargo')) {
      return false;
    }

    if (wantsPants && !primaryText.contains('pants')) {
      return false;
    }

    // Every remaining word must match the name or type.
    if (searchWords.every(primaryText.contains)) {
      return true;
    }

    // Descriptions may help general searches, but cannot
    // override a requested clothing type.
    if (requestedTypes > 0) {
      return false;
    }

    return searchWords.every(description.contains);
  }

  bool _matchesSelectedCategory(
    Map<String, dynamic> product,
  ) {
    final category = _normalize(
      (product['category'] ?? '').toString(),
    );

    switch (selectedCategory.toLowerCase().trim()) {
      case 'all':
        return true;

      case 'men':
        return category == 'men' || category == 'unisex';

      case 'women':
        return category == 'women' || category == 'unisex';

      case 'unisex':
        return category == 'unisex';

      case 'streetwear':
      case 'accessories':
        // These category values must exist in Firestore.
        return category == selectedCategory.toLowerCase();

      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final productsStream = FirebaseFirestore.instance
        .collection('catalogProducts')
        .where('isActive', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load search results. Please try again.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final documents = snapshot.data?.docs ?? [];

        final products = documents.where((document) {
          final product = document.data();

          return _matches(product, query) &&
              _matchesSelectedCategory(product);
        }).toList();

        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 44,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products found',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try another product name or category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                14,
              ),
              child: Text(
                '${products.length} product'
                '${products.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final document = products[index];
                final product = document.data();
                final rawPrice = product['price'];

                final price = rawPrice is num
                    ? rawPrice.toDouble()
                    : double.tryParse(
                          rawPrice?.toString() ?? '',
                        ) ??
                        0.0;

                return TrendingProductCard(
                  productId: document.id,
                  name: (product['name'] ?? 'Unnamed product')
                      .toString(),
                  price: 'Rs. ${price.toStringAsFixed(0)}',
                  productPrice: price,
                  imageAsset: (product['imageUrl'] ?? '')
                      .toString(),
                  description:
                      (product['description'] ?? '').toString(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
