
import 'package:cynx_cage/screens/address/address_card.dart';
import 'package:flutter/material.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Remove address?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to remove this address?',
          style: TextStyle(color: Colors.white70),
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

  @override
  Widget build(BuildContext context) {
    final addresses = _addresses;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                        color: Colors.grey.shade700,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: const Icon(
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
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gear on its way. Where to?',
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

            // Add Address button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addAddress,
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
              ),
            ),

            const SizedBox(height: 26),

            // Saved addresses
            Expanded(
              child: addresses == null
                  ? const Center(
                      child: Text(
                        'Please sign in to view your addresses.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                      stream: addresses.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Could not load addresses. Please try again.',
                              style: TextStyle(
                                color: Colors.white70,
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
                          return const Center(
                            child: Text(
                              'No saved addresses yet.',
                              style: TextStyle(
                                color: Colors.white70,
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

                              // Temporary default and selection.
                              isDefault: index == 0,
                              isSelected: index == 0,

                              onSelect: () {
  if (widget.selectionMode) {
    Navigator.pop(context, address);
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
          ],
        ),
      ),
    );
  }
}