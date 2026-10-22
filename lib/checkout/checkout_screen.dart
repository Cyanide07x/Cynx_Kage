
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — matching SettingScreen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colors.outline,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: colors.onSurface,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Text(
                        'Checkout',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Subheading
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Text(
                      'Nearly Home',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Scrollable checkout content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress steps
                    // Your order
                    // Delivery address
                    // Delivery speed
                    // Payment method
                    // Order summary

                    Text(
                      'Your order',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    
                    const SizedBox(height: 24),

                    // Add the remaining checkout sections here.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // We'll add the fixed total and Place order button here.
    );
  }
}
