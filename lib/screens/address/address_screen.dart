import 'package:cynx_cage/screens/address/address_card.dart';
import 'package:flutter/material.dart';
import 'package:cynx_cage/theme/theme_controller.dart';
import 'package:cynx_cage/theme/apptheme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_address.dart';
import 'saved_address.dart';

class AddressScreen extends StatefulWidget {
  final bool selectionMode;

  const AddressScreen({
    super.key,
    this.selectionMode = false,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? _selectedAddressId;
  SavedAddress? _selectedAddress;

  CollectionReference<Map<String, dynamic>>? get _addresses {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');
  }

  Future<void> _addAddress() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddress(),
      ),
    );
  }

  Future<void> _editAddress({
    required SavedAddress address,
    required String documentId,
  }) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddress(
          address: address,
          documentId: documentId,
        ),
      ),
    );
  }

  Future<void> _removeAddress(String documentId) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          'Remove address?',
          style: TextStyle(color: colors.onSurface),
        ),
        content: Text(
          'Are you sure you want to remove this address?',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final addresses = _addresses;

      if (addresses == null) {
        throw Exception('Please sign in to remove an address.');
      }

      await addresses.doc(documentId).delete();

      if (!mounted) return;

      if (_selectedAddressId == documentId) {
        setState(() {
          _selectedAddressId = null;
          _selectedAddress = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address removed successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove address: $e'),
        ),
      );
    }
  }

  void _selectAddress({
    required SavedAddress address,
    required String documentId,
  }) {
    setState(() {
      _selectedAddressId = documentId;
      _selectedAddress = address;
    });
  }

  void _confirmAddress() {
    if (_selectedAddress == null) return;

    Navigator.pop(context, _selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    final addresses = _addresses;

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

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
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
                            color: colors.outlineVariant,
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
                              widget.selectionMode
                                  ? 'Select Delivery Address'
                                  : 'Delivery Address',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.selectionMode
                                  ? 'Choose where your order should go.'
                                  : 'Manage your saved addresses.',
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
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addAddress,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add address'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(
                          color: colors.outlineVariant,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: addresses == null
                      ? Center(
                          child: Text(
                            'Please sign in to view your addresses.',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                          stream: addresses.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Could not load addresses. Please try again.',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final documents =
                                snapshot.data?.docs ?? [];

                            if (documents.isEmpty) {
                              return Center(
                                child: Text(
                                  'No saved addresses yet. Add one to continue.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              itemCount: documents.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final document = documents[index];
                                final data = document.data();

                                final address = SavedAddress(
                                  name: data['name'] as String? ?? '',
                                  phone: data['phone'] as String? ?? '',
                                  address:
                                      data['address'] as String? ?? '',
                                  city: data['city'] as String? ?? '',
                                  state: data['state'] as String? ?? '',
                                  pin: data['pin'] as String? ?? '',
                                );

                                return AddressCard(
                                  address: address,
                                  isDefault: false,
                                  isSelected:
                                      _selectedAddressId == document.id,
                                  onSelect: () {
                                    if (widget.selectionMode) {
                                      _selectAddress(
                                        address: address,
                                        documentId: document.id,
                                      );
                                    }
                                  },
                                  onEdit: () {
                                    _editAddress(
                                      address: address,
                                      documentId: document.id,
                                    );
                                  },
                                  onRemove: () {
                                    _removeAddress(document.id);
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),

                if (widget.selectionMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      20,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _selectedAddress == null
                            ? null
                            : _confirmAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isCynx
                              ? Colors.white
                              : const Color(0xFF263A30),
                          disabledBackgroundColor:
                              colors.surfaceContainerHighest,
                          disabledForegroundColor:
                              colors.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Deliver to this address',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}