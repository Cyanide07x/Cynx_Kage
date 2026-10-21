import 'package:flutter/material.dart';

import '../screens/wishlist/wishlist_controller.dart';
import '../screens/wishlist/wishlist_item.dart';

class WishlistIcon extends StatelessWidget {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  const WishlistIcon({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description = '',
  });

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _toggleWishlist(BuildContext context) async {
    final controller = WishlistController.instance;

    if (!controller.isSignedIn) {
      _showMessage(context, 'Please sign in to add items to your wishlist.');
      return;
    }

    final item = WishlistItem(
      productId: productId,
      name: name,
      price: price,
      description: description,
      imageUrl: imageUrl,
    );

    try {
      final added = await controller.toggleItem(item);

      if (!context.mounted) return;

      _showMessage(
        context,
        added ? 'Added to wishlist' : 'Removed from wishlist',
      );
    } catch (error) {
      if (!context.mounted) return;

      _showMessage(
        context,
        error.toString().contains('sign in')
            ? 'Please sign in to use your wishlist.'
            : 'Could not update your wishlist. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = WishlistController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final isSaved = controller.isWishlisted(productId);
        final isBusy = controller.isBusy(productId);

        return Material(
          color: Colors.black.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isBusy ? null : () => _toggleWishlist(context),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isSaved
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isSaved ? Colors.redAccent : Colors.white,
                        size: 22,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}