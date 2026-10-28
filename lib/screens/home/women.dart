// ─────────────────────────────────────────────────────────────────────────────
// screens/home/women.dart
// Product grid for the Women's category tab on the Home screen.
//
// Fetches all active products from Firestore and filters to those whose
// 'category' field equals 'women' or 'unisex' (case-insensitive).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../widgets/trending.dart';
import '../../widgets/product_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Displays a 2-column product grid for women's and unisex items.
class WomenScreen extends StatelessWidget {
  const WomenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsStream = FirebaseFirestore.instance
        .collection('catalogProducts')
        .where('isActive', isEqualTo: true)
        .snapshots();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Women's Collection",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Explore the latest styles for women.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 22),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: productsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  'Something went wrong',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Client-side filter: include 'women' and 'unisex' categories.
              final products = snapshot.data!.docs.where((doc) {
                final category = (doc.data()['category'] ?? '')
                    .toString()
                    .toLowerCase();
                return category == 'women' || category == 'unisex';
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final document = products[index];
                  final product = document.data();
                  final rawPrice = product['price'];
                  final price = rawPrice is num
                      ? rawPrice.toDouble()
                      : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

                  final fullProduct = <String, dynamic>{
                    ...product,
                    'id': document.id,
                  };

                  return TrendingProductCard(
                    productId: document.id,
                    name: (product['name'] ?? 'Unnamed product').toString(),
                    price: 'Rs. ${price.toStringAsFixed(0)}',
                    productPrice: price,
                    imageAsset: (product['imageUrl'] ?? '').toString(),
                    description: (product['description'] ?? '').toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ProductPage(product: fullProduct),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}