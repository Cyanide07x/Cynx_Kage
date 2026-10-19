// ─────────────────────────────────────────────────────────────────────────────
// screens/home/unisex.dart
// Product grid for the Unisex category tab on the Home screen.
//
// Fetches all active products from Firestore and filters to those whose
// 'category' field equals 'unisex' (case-insensitive).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../widgets/trending.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Displays a 2-column product grid for unisex items only.
class UnisexScreen extends StatelessWidget {
  const UnisexScreen({super.key});

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
              'Unisex Collection',
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
              'Explore the latest styles for everyone.',
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

              // Client-side filter: include 'unisex' category only.
              final products = snapshot.data!.docs.where((doc) {
                final category = (doc.data()['category'] ?? '')
                    .toString()
                    .toLowerCase();
                return category == 'unisex';
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
                  final product = products[index].data();

                  return TrendingProductCard(
                    name: (product['name'] ?? 'Unnamed product').toString(),
                    price: 'Rs. ${(product['price'] ?? 0).toString()}',
                    imageAsset: (product['imageUrl'] ?? '').toString(),
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