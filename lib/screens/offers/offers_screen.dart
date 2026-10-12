import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../widgets/offer_filter_button.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}