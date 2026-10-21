
import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import '../../theme/apptheme.dart';
import '../../theme/theme_controller.dart';
import 'account_action_button.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _showThemePicker(BuildContext context) {
    final currentTheme = themeController.selectedTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Theme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personalize your app appearance.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 20),
                _themeOption(
                  context: sheetContext,
                  title: 'Forest',
                  subtitle: 'Lime green accents',
                  color: AppColors.forestPrimary,
                  selected: currentTheme == CynxThemeMode.forest,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTheme(context, CynxThemeMode.forest);
                  },
                ),
                const SizedBox(height: 12),
                _themeOption(
                  context: sheetContext,
                  title: 'Cynx',
                  subtitle: 'Hot pink accents',
                  color: AppColors.cynxPrimary,
                  selected: currentTheme == CynxThemeMode.cynx,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _selectTheme(context, CynxThemeMode.cynx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTheme(
    BuildContext context,
    CynxThemeMode theme,
  ) async {
    try {
      await themeController.setTheme(theme);
      debugPrint('Selected theme: ${themeController.selectedTheme}');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Theme changed to '
            '${theme == CynxThemeMode.forest ? 'Forest' : 'Cynx'}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save theme preference.'),
        ),
      );
    }
  }

  Widget _themeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 8,
              backgroundColor: color,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          Navigator.of(context).maybePop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Preferences
              Text(
                'PREFERENCES',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              AccountActionButton(
                icon: Icons.palette_outlined,
                title: 'Theme',
                onTap: () => _showThemePicker(context),
              ),

              const SizedBox(height: 12),

              AccountActionButton(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile screen coming soon'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Account security
              Text(
                'ACCOUNT SECURITY',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              AccountActionButton(
                icon: Icons.lock_reset_outlined,
                title: 'Forgot Password',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
