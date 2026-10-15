import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../Widgets/trending.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WomenScreen extends StatelessWidget {
  const WomenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsStream = FirebaseFirestore.instance
    .collection('catalogProducts')
    .where('isActive', isEqualTo: true)
    .snapshots();


    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 25, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "women's Collection",
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
      return const Text('Something went wrong');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Your GridView.builder will go here next.
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
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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