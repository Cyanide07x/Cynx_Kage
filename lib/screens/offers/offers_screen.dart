
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 20),
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
                      // Flash sale
                      if (selectedFilter != 'Coupons') ...[
                        SizedBox(
                          width: double.infinity,
                          child: FlashSaleCard(
                            endsAt: DateTime.now().add(
                              const Duration(days: 15),
                            ),
                            onShopNow: () {
                              // Connect sale products later.
                            },
                          ),
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
                          description: 'On your orders above RS. 1999',
                          code: 'OVER1999',
                        ),
                        const SizedBox(height: 12),

                        const CouponCard(
                          discount: 'Buy 2 Get 1',
                          description: 'On your first order',
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
