
import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class FlashSaleCard extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback? onShopNow;

  const FlashSaleCard({
    super.key,
    required this.endsAt,
    this.onShopNow,
  });

  @override
  State<FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<FlashSaleCard> {
  late Timer _timer;
  late Duration remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final difference = widget.endsAt.difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      remaining = difference.isNegative
          ? Duration.zero
          : difference;
    });
  }

  @override
  void didUpdateWidget(covariant FlashSaleCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.endsAt != widget.endsAt) {
      _updateRemaining();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _twoDigits(int value) =>
      value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    final isExpired = remaining == Duration.zero;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FLASH SALE',
            style: TextStyle(
              color: AppColors.appBackground,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'UP TO 50%\nOFF',
            style: TextStyle(
              color: AppColors.appBackground,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'On streetwear, hoodies & more',
            style: TextStyle(
              color: AppColors.deepForest,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _timeBox(_twoDigits(hours)),
              const SizedBox(width: 5),
              _timeBox(_twoDigits(minutes)),
              const SizedBox(width: 5),
              _timeBox(_twoDigits(seconds)),
              const Spacer(),
              FilledButton(
                onPressed: isExpired ? null : widget.onShopNow,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.appBackground,
                  foregroundColor: AppColors.text,
                  disabledBackgroundColor: AppColors.deepForest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  isExpired ? 'Sale ended' : 'Shop now',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
