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

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    const HomeScreen(showNavigation: false),
    const WishlistScreen(),
    const OfferScreen(),
    const AccountScreen(),
  ];

  void _handleBack(bool didPop) {
    if (didPop) return;

    if (selectedIndex != 0) {
      setState(() {
        selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        _handleBack(didPop);
      },
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
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
                  child: KeyedSubtree(
                    key: ValueKey<int>(selectedIndex),
                    child: pages[selectedIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
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