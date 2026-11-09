import 'package:cynx_cage/screens/address/address_card.dart';
import 'package:flutter/material.dart';
import 'package:cynx_cage/theme/theme_controller.dart';
import 'package:cynx_cage/theme/apptheme.dart';

import '../../services/address_service.dart';
import '../../services/auth_service.dart';
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
  final AddressService _addressService = AddressService();
  final AuthService _authService = AuthService();

  List<SavedAddress> _addresses = [];
  bool _isLoading = true;
  bool _isSignedIn = false;
  String? _errorMessage;

  int? _selectedAddressId;
  SavedAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _authService.getAccessToken();
      _isSignedIn = token != null && token.isNotEmpty;

      if (!_isSignedIn) {
        setState(() {
          _addresses = [];
          _isLoading = false;
        });
        return;
      }

      final items = await _addressService.fetchAddresses();

      setState(() {
        _addresses = items;
        _isLoading = false;

        // In selection mode, auto-select the default or first address if nothing is selected yet
        if (widget.selectionMode && _selectedAddress == null && items.isNotEmpty) {
          final defaultAddr = items.firstWhere(
            (a) => a.isDefault,
            orElse: () => items.first,
          );
          _selectedAddress = defaultAddr;
          _selectedAddressId = defaultAddr.addressId;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _addAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddress(),
      ),
    );

    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _editAddress(SavedAddress address) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddress(
          address: address,
          addressId: address.addressId,
        ),
      ),
    );

    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _removeAddress(SavedAddress address) async {
    if (address.addressId == null) return;

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
      await _addressService.deleteAddress(address.addressId!);

      if (!mounted) return;

      if (_selectedAddressId == address.addressId) {
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

      _loadAddresses();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove address: $e'),
        ),
      );
    }
  }

  void _selectAddress(SavedAddress address) {
    setState(() {
      _selectedAddressId = address.addressId;
      _selectedAddress = address;
    });
  }

  void _confirmAddress() {
    if (_selectedAddress == null) return;
    Navigator.pop(context, _selectedAddress);
  }

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
                  child: _buildAddressList(colors),
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

  Widget _buildAddressList(ColorScheme colors) {
    if (!_isSignedIn) {
      return Center(
        child: Text(
          'Please sign in to view your addresses.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadAddresses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_addresses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAddresses,
        child: ListView(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Text(
                'No saved addresses yet. Add one to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAddresses,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
        itemCount: _addresses.length,
        separatorBuilder: (_, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final address = _addresses[index];
          final isSelected = _selectedAddressId == address.addressId;

          return AddressCard(
            address: address,
            isDefault: address.isDefault,
            isSelected: isSelected,
            onSelect: () {
              if (widget.selectionMode) {
                _selectAddress(address);
              }
            },
            onEdit: () => _editAddress(address),
            onRemove: () => _removeAddress(address),
          );
        },
      ),
    );
  }
}
