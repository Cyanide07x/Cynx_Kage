
import 'package:flutter/material.dart';
import 'payment_method_card.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'COD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF333333),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  // Centered title
                  const Expanded(
                    child: Text(
                      'Payment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Balances the back button
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Amount to pay
            const SizedBox(height: 24),

            const Text(
              'Amount to pay',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '₹${widget.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),

            // Space before payment method
            const SizedBox(height: 32),

            // Cash on delivery card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PaymentMethodCard(
                icon: Icons.payments_outlined,
                title: 'Cash on delivery',
                subtitle: 'Pay when it arrives',
                isSelected: _selectedPaymentMethod == 'COD',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'COD';
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Cash on delivery card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PaymentMethodCard(
                icon: Icons.phone_iphone_outlined,
                title: 'UPI',
                subtitle: 'Paytm, Google pay, Phone Pe',
                isSelected: _selectedPaymentMethod == 'UPI',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'UPI';
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Cash on delivery card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PaymentMethodCard(
                icon: Icons.credit_card_outlined,
                title: 'Card',
                subtitle: 'Debit/Credit',
                isSelected: _selectedPaymentMethod == 'CARD',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'CARD';
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
