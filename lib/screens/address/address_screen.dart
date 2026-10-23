import 'package:cynx_cage/screens/address/address_card.dart';
import 'package:flutter/material.dart';
import 'add_Address.dart';
import 'saved_address.dart';

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
              Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 1,
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
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gear on its way. Where to?.',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],  
          ),
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddress(),
      ),
    );
  },
  icon: const Icon(Icons.add, size: 20),
  label: const Text('Add address'),
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.grey),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),


const SizedBox(height: 26),

AddressCard(
  address: const SavedAddress(
    name: 'Test User',
    phone: '9876543210',
    address: '123 Main Street',
    city: 'Gwalior',
    state: 'Madhya Pradesh',
    pin: '474001',
  ),
  isDefault: true,
  isSelected: true,
  onSelect: () {},
  onEdit: () {},
  onRemove: () {},
),
        ],
        
      )
      )
      
    );
  }
}