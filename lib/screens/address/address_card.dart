
import 'package:flutter/material.dart';
import 'saved_address.dart'; // Change this to your actual model file path.

class AddressCard extends StatelessWidget {
  final SavedAddress address;
  final bool isDefault;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const AddressCard({
    super.key,
    required this.address,
    this.isDefault = false,
    this.isSelected = false,
    required this.onSelect,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFD2E66B);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(
          color: isSelected ? lime : Colors.grey.shade800,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name, address type, and default label
          Row(
            children: [
              GestureDetector(
                onTap: onSelect,
                child: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? lime : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  address.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'HOME',
                  style: TextStyle(
                    color: lime,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isDefault) ...[
                const SizedBox(width: 8),
                const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Address details
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.address,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${address.city}, ${address.state} - ${address.pin}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address.phone,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Divider(color: Colors.grey.shade800, height: 1),

          const SizedBox(height: 8),

          // Edit and Remove actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade800),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade800),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
