
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'cart_item.dart';

class CartCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 85,
              height: 105,
              color: colors.surfaceContainerHighest,
              child: item.imageUrl.isEmpty
                  ? Icon(
                      Icons.image_outlined,
                      color: colors.onSurfaceVariant,
                      size: 30,
                    )
                  : CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 250,
                      placeholder: (context, url) => Container(
                        color: colors.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.broken_image_outlined,
                        color: colors.onSurfaceVariant,
                        size: 30,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Size ${item.size} · ${item.color}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                // Quantity controls
                Row(
                  children: [
                    _quantityButton(
                      context: context,
                      icon: Icons.remove,
                      onTap: item.quantity > 1
                          ? () => onQuantityChanged(item.quantity - 1)
                          : null,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    _quantityButton(
                      context: context,
                      icon: Icons.add,
                      onTap: () =>
                          onQuantityChanged(item.quantity + 1),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: onRemove,
                      tooltip: 'Remove item',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Icon(
                        Icons.delete_outline,
                        color: colors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Total for this item
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: ₹${item.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 29,
      height: 29,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 15),
        color: colors.onSurface,
        style: IconButton.styleFrom(
          side: BorderSide(color: colors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
