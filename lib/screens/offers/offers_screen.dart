
import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/offer_filter_button.dart';
import '../../widgets/flash_sale_card.dart';
import '../../widgets/coupon_card.dart';
import '../navigation/navigation_shell.dart';
import '../../services/coupon_service.dart';
import '../../models/coupon_model.dart';

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
  final CouponService _couponService = CouponService();
  late Future<List<CouponModel>> _couponsFuture;

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
        NavigationShell.switchToTab(context, 0);
      },
    ),
    FlashSaleCard(
      endsAt: newArrivalsSaleEnd,
      saleTitle: 'NEW ARRIVALS',
      discountText: '30% OFF',
      description: 'Discover our latest collection',
      onShopNow: () {
        NavigationShell.switchToTab(context, 0);
      },
    ),

    // Add a third FlashSaleCard here whenever you need one.
  ];

  @override
  void initState() {
    super.initState();
    _couponsFuture = _couponService.fetchCoupons();

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
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offers',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deals made for movers.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                flashSales.length,
                                (index) {
                                  final isActive =
                                      currentFlashIndex == index;

                                  return AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 250,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: isActive ? 22 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? colors.primary
                                          : colors.outlineVariant,
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
                        Text(
                          'Your coupons',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildCouponsSection(colors),
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

  Widget _buildCouponsSection(ColorScheme colors) {
    return FutureBuilder<List<CouponModel>>(
      future: _couponsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Unable to load coupons.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
          );
        }

        final validCoupons = snapshot.data ?? [];

        if (validCoupons.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Center(
              child: Text(
                'No active coupons available right now.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return Column(
          children: validCoupons.map((coupon) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CouponCard(
                discount: coupon.discountBadgeText,
                description: coupon.description,
                code: coupon.code,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
