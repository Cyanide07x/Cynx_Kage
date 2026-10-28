
import 'package:flutter/material.dart';
import '../screens/cart/cart_controller.dart';

/// Persistent top bar displayed at the top of [NavigationShell].
///
/// Contains:
/// - The "CYNX KAGE" wordmark on the left.
/// - A notification bell icon on the right.
/// - A shopping-bag icon on the right.
class Header extends StatelessWidget {
  /// Called when the notification bell icon is tapped.
  final VoidCallback? onNotificationTap;

  /// Called when the shopping-bag icon is tapped.
  final VoidCallback? onCartTap;

  const Header({
    super.key,
    this.onNotificationTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Brand wordmark
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'CYNX KAGE',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          const Spacer(),

          // Action icons
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: colors.onSurfaceVariant,
            onPressed: onNotificationTap,
          ),
          ListenableBuilder(
            listenable: CartController.instance,
            builder: (context, _) {
              final count = CartController.instance.totalCount;

              return Badge.count(
                count: count,
                isLabelVisible: count > 0,
                backgroundColor: colors.primary,
                textColor: colors.onPrimary,
                alignment: const AlignmentDirectional(0.7, -0.6),
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  color: colors.onSurfaceVariant,
                  onPressed: onCartTap,
                ),
              );
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
