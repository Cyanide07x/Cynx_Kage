import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';
import '../../theme/apptheme.dart';
import 'saved_address.dart';

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
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final isCynx =
            themeController.selectedTheme == CynxThemeMode.cynx;

        final accent = isCynx
            ? const Color(0xFFE50046)
            : const Color(0xFFBBD58E);

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(
                  color: isSelected
                      ? accent
                      : colors.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? accent
                            : colors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          address.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
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
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'HOME',
                          style: TextStyle(
                            color: accent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Default',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.address,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),

                        Text(
                          '${address.city}, ${address.state} - ${address.pin}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),

                        Text(
                          address.phone,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Divider(
                    color: colors.outlineVariant,
                    height: 1,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 14,
                        ),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          side: BorderSide(
                            color: colors.outlineVariant,
                          ),
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
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 14,
                        ),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          side: BorderSide(
                            color: colors.outlineVariant,
                          ),
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
            ),
          ),
        );
      },
    );
  }
}