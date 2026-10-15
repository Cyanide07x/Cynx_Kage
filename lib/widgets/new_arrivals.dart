
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/appcolors.dart';

class NewArrivals extends StatefulWidget {
  const NewArrivals({super.key});

  @override
  State<NewArrivals> createState() => _NewArrivalsState();
}

class _NewArrivalsState extends State<NewArrivals>
    with SingleTickerProviderStateMixin {
  final Set<String> wishlistedProducts = {};
  final PageController _pageController = PageController();

  Timer? _timer;
  int _currentPage = 0;

  late AnimationController _newAnimationController;

  final Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream =
      FirebaseFirestore.instance
          .collection('catalogProducts')
          .where('isActive', isEqualTo: true)
          .snapshots();

  @override
  void initState() {
    super.initState();

    _newAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_pageController.hasClients) return;

      final page = _pageController.page?.round() ?? 0;
      final nextPage = page + 1;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _newAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Arrivals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
  debugPrint('Firestore error: ${snapshot.error}');

  return SizedBox(
    height: 325,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          'Firestore error:\n${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    ),
  );
}

            if (!snapshot.hasData) {
              return const SizedBox(
                height: 325,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final products = snapshot.data!.docs.where((doc) {
              final data = doc.data();
              return data['isNewArrival'] == true;
            }).toList()
              ..sort((a, b) {
                final aOrder = a.data()['sortOrder'] as num? ?? 0;
                final bOrder = b.data()['sortOrder'] as num? ?? 0;
                return aOrder.compareTo(bOrder);
              });

            if (products.isEmpty) {
              return const SizedBox(
                height: 325,
                child: Center(
                  child: Text(
                    'No new arrivals yet.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            final safePage = _currentPage % products.length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 325,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.text,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: products.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final data = products[index].data();
                              final imageUrl =
                                  data['imageUrl'] as String? ?? '';

                              if (imageUrl.isEmpty) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                );
                              }

                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        Positioned(
                          top: 12,
                          left: 12,
                          child: FadeTransition(
                            opacity: _newAnimationController,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '* NEW',
                                style: TextStyle(
                                  color: AppColors.deepForest,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                wishlistedProducts.contains(
                                  products[safePage].id,
                                )
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              color: wishlistedProducts.contains(
                                products[safePage].id,
                              )
                                  ? Colors.red
                                  : AppColors.text,
                              onPressed: () {
                                setState(() {
                                  final id = products[safePage].id;
                                  if (!wishlistedProducts.add(id)) {
                                    wishlistedProducts.remove(id);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    products.length,
                    (index) => _dot(index == safePage),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
