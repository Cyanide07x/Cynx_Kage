
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(
          color: const Color(0xFFD2E66B),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top row
          Row(
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: Color(0xFFD2E66B),
                size: 20,
              ),
              const SizedBox(width: 10),

              const Text(
                '[Your name]',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD2E66B)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'HOME',
                  style: TextStyle(
                    color: Color(0xFFD2E66B),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'Default',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. Address details
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[HOUSE NO., STREET], [CITY]',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),

                Text(
                  '[PINCODE]',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),

                Text(
                  '[PHONE NUMBER]',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Divider
          Divider(
            color: Colors.grey.shade800,
            height: 1,
          ),

          const SizedBox(height: 8),

          // 4. Action buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                ),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.delete_outline,
                  size: 14,
                ),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
