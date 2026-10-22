import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget{
  const CheckoutScreen ({super.key});


  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: const Center(
        child: Text('Welcome to Checkout'),
      ),
    );
  }
}