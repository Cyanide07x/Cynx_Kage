
import 'package:flutter/material.dart';
import 'package:cynx_cage/theme/theme_controller.dart';
import 'package:cynx_cage/theme/apptheme.dart';

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isCynx =
        themeController.selectedTheme == CynxThemeMode.cynx;

    final accentColor = isCynx
        ? const Color(0xFFE50046)
        : const Color(0xFFBBD58E);

    final textColor = enabled
        ? colors.onSurface
        : colors.onSurface.withValues(alpha: 0.4);

    final subtitleColor = enabled
        ? colors.onSurfaceVariant
        : colors.onSurfaceVariant.withValues(alpha: 0.4);

    final borderColor = isSelected
        ? accentColor
        : colors.outlineVariant;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled
                  ? accentColor
                  : colors.onSurfaceVariant.withValues(alpha: 0.4),
              size: 22,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? accentColor
                  : colors.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
