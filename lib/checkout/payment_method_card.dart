import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget{

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  const PaymentMethodCard({super.key,
  required this.icon,
  required this.title,
  required this.subtitle,
  required this.isSelected,
  required this.onTap,
  this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFC5E86C);
    const borderColor= Color(0xFF333333);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, color: enabled ? accentColor : Colors.grey,
          size: 22,
          ),
          const SizedBox(width: 16),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(
              title,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color : Color(0xFF999999),
                fontSize: 12,
              ),
            ),
            ],
          ),
          ),
          Icon(isSelected ?
          Icons.radio_button_checked: Icons.radio_button_unchecked,
          color: isSelected ? accentColor: borderColor,
          size: 22,
          ),
        ],
        ),
      ),
    );
  }
}