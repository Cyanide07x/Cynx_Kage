
import 'dart:async';

import 'package:flutter/material.dart';

class FlashSaleCard extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback? onShopNow;

  // Custom content for each sale
  final String saleTitle;
  final String discountText;
  final String description;

  const FlashSaleCard({
    super.key,
    required this.endsAt,
    this.onShopNow,
    this.saleTitle = 'FLASH SALE',
    this.discountText = 'UP TO 50%\nOFF',
    this.description = 'On streetwear, hoodies & more',
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
      remaining = difference.isNegative ? Duration.zero : difference;
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

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    final isExpired = remaining == Duration.zero;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.saleTitle,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.discountText,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.description,
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: 0.8),
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
                  backgroundColor: colors.surface,
                  foregroundColor: colors.onSurface,
                  disabledBackgroundColor: colors.onPrimary.withValues(
                    alpha: 0.25,
                  ),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: colors.primary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
