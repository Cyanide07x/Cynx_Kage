import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget{
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState
extends State<AddressScreen> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            children: [
              IconButton(onPressed: () {
                Navigator.pop(context);
              },
              
              
              
               icon:  const Icon(Icons.arrow_back,
               size: 20,
               ) ,
               ),


               const SizedBox(width: 8),
               const Text(
                'Delivery Address',
                style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                ),
               )
            ],
          ),
          
          )

        ],
      ))
    );
  }
}