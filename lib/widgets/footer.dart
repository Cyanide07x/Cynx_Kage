
import 'package:flutter/material.dart';

/// Bottom navigation bar with four tabs and an animated selection indicator.
///
/// Tab order: Home - Wishlist - Offers - Account
class Footer extends StatelessWidget {
  /// The index of the currently selected tab (0-based).
  final int selectedIndex;

  /// Callback invoked with the tapped tab index.
  final ValueChanged<int> onTabSelected;

  const Footer({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  /// Icons for each tab in order: Home, Wishlist, Offers, Account.
  final List<IconData> icons = const [
    Icons.home_outlined,
    Icons.favorite_border,
    Icons.local_offer_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = selectedIndex == index;

          return InkWell(
            onTap: () => onTabSelected(index),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tab icon
                  Icon(
                    icons[index],
                    color: isSelected
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 5),

                  // Animated underline dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: isSelected ? 20 : 4,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
