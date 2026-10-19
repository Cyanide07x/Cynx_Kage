// ─────────────────────────────────────────────────────────────────────────────
// screens/home/men.dart
// Product grid for the Men's category tab on the Home screen.
//
// Fetches all active products from Firestore and filters to those whose
// 'category' field equals 'men' or 'unisex' (case-insensitive).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../widgets/trending.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Displays a 2-column product grid for men's and unisex items.
///
/// Listens to the Firestore `catalogProducts` collection and renders each
/// matching product as a [TrendingProductCard].
class MenScreen extends StatelessWidget {
  const MenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Real-time stream of all active products; category filtering is done
    // client-side because Firestore does not support OR queries on the same
    // field without a composite index.
    final productsStream = FirebaseFirestore.instance
        .collection('catalogProducts')
        .where('isActive', isEqualTo: true)
        .snapshots();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section heading ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Men's Collection",
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
              'Explore the latest styles for men.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ── Product grid ────────────────────────────────────────────
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

              // Client-side filter: include 'men' and 'unisex' categories.
              final products = snapshot.data!.docs.where((doc) {
                final category = (doc.data()['category'] ?? '')
                    .toString()
                    .toLowerCase();
                return category == 'men' || category == 'unisex';
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