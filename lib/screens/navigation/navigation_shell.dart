// ─────────────────────────────────────────────────────────────────────────────
// screens/navigation/navigation_shell.dart
// Persistent shell that owns the bottom navigation bar and top header.
//
// Tab order:
//   0 – Home      (HomeScreen)
//   1 – Wishlist  (WishlistScreen)
//   2 – Offers    (OfferScreen)
//   3 – Account   (AccountScreen)
//
// Cart and Notifications are pushed as separate full-screen routes from the
// [Header] widget; they are intentionally NOT tabs.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cynx_cage/screens/cart/cart_screen.dart';
import 'package:cynx_cage/screens/notifications/notification_screen.dart';
import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import '../../widgets/header.dart';
import '../../widgets/footer.dart';

import '../home/home_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../account/account_screen.dart';
import '../offers/offers_screen.dart';

/// The main scaffold that persists across all bottom-nav tabs.
///
/// It combines:
/// - A top [Header] (logo + notification + cart icons)
/// - An [AnimatedSwitcher] for smooth tab transitions
/// - A [Footer] bottom navigation bar
///
/// Back-button behaviour: pressing back while on a non-home tab returns the
/// user to the Home tab instead of exiting the app.
class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  /// Index of the currently active bottom-nav tab (0 = Home).
  int selectedIndex = 0;

  /// Lazily-constructed list of tab screens.
  /// `HomeScreen(showNavigation: false)` hides its own header because the
  /// shell's [Header] already provides it.
  late final List<Widget> pages = [
    const HomeScreen(showNavigation: false),
    const WishlistScreen(),
    const OfferScreen(),
    const AccountScreen(),
  ];

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Intercepts Android back-button presses.
  ///
  /// If the user is on a non-home tab, we navigate back to Home instead of
  /// popping the entire route (which would exit the app).
  void _handleBack(bool didPop) {
    if (didPop) return;

    if (selectedIndex != 0) {
      setState(() {
        selectedIndex = 0;
      });
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Allow a real pop only when already on the Home tab.
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) => _handleBack(didPop),
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top header (logo, notifications, cart) ──────────────────
              Header(
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                onCartTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),

              // ── Tab content with fade + slide transition ─────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  // ValueKey forces a full rebuild when the tab changes.
                  child: KeyedSubtree(
                    key: ValueKey<int>(selectedIndex),
                    child: pages[selectedIndex],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Bottom navigation bar ────────────────────────────────────────────
        bottomNavigationBar: SafeArea(
          top: false,
          child: Footer(
            selectedIndex: selectedIndex,
            onTabSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}