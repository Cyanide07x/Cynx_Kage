import 'package:flutter/material.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen ({super.key});

  @override
  State<PaymentScreen> createState () => _PaymentScreen();

}

class _PaymentScreen extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Text('Payment', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,

          ),),
  
        ),
      )
    );
  }
}