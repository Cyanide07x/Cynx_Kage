import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget{
  const AddressCard({super.key});


    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(12),
        //Box deco
        decoration: BoxDecoration(
          color: const Color(0xff141414),
          border: Border.all(
            color: const Color(0xFFD2E66B),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(Icons.radio_button_checked,
              color: Color(0xFFD2E66B),
              size: 20,
              ),
              const SizedBox(width: 10),
              const Text('[Your name]',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              ),
            ],
          ),
        ],
        ),
      );
  }
}