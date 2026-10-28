
import 'dart:io';

import 'package:cynx_cage/screens/address/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setting_screen.dart';
import 'support_screen.dart';

import '../login/login_screen.dart';
import 'tracker.dart';
import 'account_action_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orders/my_order.dart';
import '../navigation/navigation_shell.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  String? _photoPath;
  bool _isSavingProfile = false;

  User? get _user => _auth.currentUser;

  String get _displayName {
    final name = _user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'User';
  }

  String get _email => _user?.email ?? '';

  String get _initials {
    final parts = _displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty || _displayName == 'User') return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadPhotoPath();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profilePhotoPath');
    if (!mounted) return;

    setState(() {
      _photoPath = path;
    });
  }

  Future<void> _choosePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (image == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profilePhotoPath', image.path);

      if (!mounted) return;
      setState(() {
        _photoPath = image.path;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select the photo. Please try again.'),
        ),
      );
    }
  }

  Future<void> _editProfile() async {
    _nameController.text = _user?.displayName ?? '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final theme = Theme.of(dialogContext);
            final colors = theme.colorScheme;
            final hasPhoto = _photoPath != null &&
                File(_photoPath!).existsSync();

            return AlertDialog(
              backgroundColor: colors.surface,
              title: Text(
                'Edit profile',
                style: TextStyle(color: colors.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _choosePhoto();
                        if (!mounted || !dialogContext.mounted) return;
                        setDialogState(() {});
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surfaceContainerHighest,
                              border: Border.all(
                                color: colors.primary,
                                width: 2,
                              ),
                              image: hasPhoto
                                  ? DecorationImage(
                                      image: FileImage(File(_photoPath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !hasPhoto
                                ? Center(
                                    child: Text(
                                      _initials,
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the avatar to change photo',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Display name',
                        labelStyle: TextStyle(
                          color: colors.onSurfaceVariant,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colors.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colors.primary,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _email,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSavingProfile
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSavingProfile
                      ? null
                      : () async {
                          final name = _nameController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Display name cannot be empty.',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => _isSavingProfile = true);
                          setDialogState(() {});

                          try {
                            final user = _auth.currentUser;
                            if (user == null) {
                              throw FirebaseAuthException(
                                code: 'user-not-signed-in',
                                message: 'Please sign in again.',
                              );
                            }

                            await user.updateDisplayName(name);
                            await user.reload();

                            if (!mounted || !dialogContext.mounted) return;

                            setState(() {
                              _isSavingProfile = false;
                            });

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile updated successfully.',
                                ),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!mounted || !dialogContext.mounted) return;

                            setState(() {
                              _isSavingProfile = false;
                            });
                            setDialogState(() {});

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.message ?? 'Could not update profile.',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!mounted || !dialogContext.mounted) return;

                            setState(() {
                              _isSavingProfile = false;
                            });
                            setDialogState(() {});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not update profile.'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: _isSavingProfile
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Account header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.outlineVariant,
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
                        color: colors.onSurface,
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
                          'Account',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your gear, your rules.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Profile section
              const SizedBox(height: 32),

              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(
                        color: colors.primary,
                        width: 2,
                      ),
                      image: _photoPath != null &&
                              File(_photoPath!).existsSync()
                          ? DecorationImage(
                              image: FileImage(File(_photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _photoPath == null ||
                            !File(_photoPath!).existsSync()
                        ? Center(
                            child: Text(
                              _initials,
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit profile',
                      onPressed: _editProfile,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),

              // Tracker boxes
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _auth.currentUser == null
                          ? null
                          : FirebaseFirestore.instance
                              .collection('orders')
                              .where(
                                'userId',
                                isEqualTo: _auth.currentUser!.uid,
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return Tracker(
                          count: count.toString().padLeft(2, '0'),
                          title: 'Orders',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _auth.currentUser == null
                          ? null
                          : FirebaseFirestore.instance
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('wishlist')
                              .snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return Tracker(
                          count: count.toString().padLeft(2, '0'),
                          title: 'Wishlist',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('coupons')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final now = DateTime.now();

                        final validCount = docs.where((doc) {
                          final data = doc.data();
                          final expiresAt = data['expiresAt'];
                          if (expiresAt is Timestamp &&
                              expiresAt.toDate().isBefore(now)) {
                            return false;
                          }
                          final maxUses = (data['maxUses'] as num?)?.toInt();
                          final usedCount = (data['usedCount'] as num?)?.toInt() ?? 0;
                          if (maxUses != null && usedCount >= maxUses) {
                            return false;
                          }
                          return true;
                        }).length;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            NavigationShell.switchToTab(context, 2);
                          },
                          child: Tracker(
                            count: validCount.toString().padLeft(2, '0'),
                            title: 'Coupons',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Account action buttons
              const SizedBox(height: 24),

              AccountActionButton(
                icon: Icons.shopping_bag_outlined,
                title: 'My Orders',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyOrdersScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AccountActionButton(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => const AddressScreen(),
                      ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AccountActionButton(
                icon: Icons.credit_card_outlined,
                title: 'Payment methods',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment clicked!'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AccountActionButton(
                icon: Icons.headset_mic_outlined,
                title: 'Help & Support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AccountActionButton(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AccountActionButton(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () async {
                  try {
                    await _auth.signOut();

                    if (!context.mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } catch (_) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to log out. Please try again.',
                        ),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
