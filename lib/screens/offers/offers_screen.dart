import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import '../../widgets/offer_filter_button.dart';
import '../../widgets/flash_sale_card.dart';
import '../../widgets/coupon_card.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  String selectedFilter = 'All';

  int currentFlashIndex = 0;
  Timer? _carouselTimer;

  final PageController _pageController = PageController();

  // Independent deadlines for each sale.
  late final DateTime streetwearSaleEnd =
      DateTime.now().add(const Duration(days: 15));

  late final DateTime newArrivalsSaleEnd =
      DateTime.now().add(const Duration(days: 10));

  // Add future flash-sale cards to this list.
  // The carousel and indicators automatically adapt to its length.
  late final List<Widget> flashSales = [
    FlashSaleCard(
      endsAt: streetwearSaleEnd,
      saleTitle: 'FLASH SALE',
      discountText: 'UP TO 50%\nOFF',
      description: 'On streetwear, hoodies & more',
      onShopNow: () {
        // Connect streetwear products later.
      },
    ),
    FlashSaleCard(
      endsAt: newArrivalsSaleEnd,
      saleTitle: 'NEW ARRIVALS',
      discountText: '30% OFF',
      description: 'Discover our latest collection',
      onShopNow: () {
        // Connect new-arrival products later.
      },
    ),

    // Add a third FlashSaleCard here whenever you need one.
  ];

  @override
  void initState() {
    super.initState();

    _carouselTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!mounted ||
            !_pageController.hasClients ||
            selectedFilter == 'Coupons' ||
            flashSales.length < 2) {
          return;
        }

        final nextIndex = currentFlashIndex + 1;

if (nextIndex < flashSales.length) {
  _pageController.animateToPage(
    nextIndex,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );
} else {
  // Loop from the last card back to the first.
  _pageController.jumpToPage(0);
}
      },
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offers',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Deals made for movers.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Offer filter buttons
              Row(
                children: [
                  OfferFilterButton(
                    title: 'All',
                    isSelected: selectedFilter == 'All',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'All';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  OfferFilterButton(
                    title: 'Coupons',
                    isSelected: selectedFilter == 'Coupons',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Coupons';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  OfferFilterButton(
                    title: 'Flash deals',
                    isSelected: selectedFilter == 'Flash deals',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Flash deals';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Scrollable offer content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic flash-sale carousel
                      if (selectedFilter != 'Coupons' &&
                          flashSales.isNotEmpty) ...[
                        Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: flashSales.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentFlashIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 4),
                                    child: flashSales[index],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Dynamic dot indicators
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: List.generate(
                                flashSales.length,
                                (index) {
                                  final isActive =
                                      currentFlashIndex == index;

                                  return AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 250,
                                    ),
                                    margin:
                                        const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: isActive ? 22 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.border,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],

                      // Coupons section
                      if (selectedFilter != 'Flash deals') ...[
                        const Text(
                          'Your coupons',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        const CouponCard(
                          discount: '20%',
                          description: 'On your first order',
                          code: 'FIRST20',
                        ),
                        const SizedBox(height: 12),

                        const CouponCard(
                          discount: '50%',
                          description:
                              'On your orders above RS. 1999',
                          code: 'OVER1999',
                        ),
                        const SizedBox(height: 12),

                        const CouponCard(
                          discount: 'B2G1',
                          description: 'Buy 2 Get 1 On your first order',
                          code: 'B2G1',
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}