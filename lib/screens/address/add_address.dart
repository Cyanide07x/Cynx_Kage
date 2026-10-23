
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddAddress> {
  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController phoneController =
      TextEditingController();
  final TextEditingController addressController =
      TextEditingController();
  final TextEditingController cityController =
      TextEditingController();
  final TextEditingController stateController =
      TextEditingController();
  final TextEditingController pinController =
      TextEditingController();

      
Future<void> _saveAddress() async {
  // 1. Check whether a user is signed in.
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please sign in to save your address.'),
      ),
    );
    return;
  }

  // 2. Save the address under this user's account.
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .add({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'pin': pinController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address saved successfully!'),
      ),
    );

    // Return to the previous screen after saving.
    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save address: $e'),
      ),
    );
  }
}


  Widget addressField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFF1C1C1C),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade800,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
return GestureDetector(
  onTap: () {
    FocusScope.of(context).unfocus();
  },
  child: Scaffold(
    backgroundColor: const Color(0xFF101010),
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
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Address',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Where should we send it?',
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

            // Address fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addressField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: nameController,
                    ),
                    const SizedBox(height: 20),

                    addressField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    addressField(
                      label: 'Street Address',
                      hint: 'House no., street, area',
                      controller: addressController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: addressField(
                            label: 'City',
                            hint: 'Enter city',
                            controller: cityController,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: addressField(
                            label: 'State',
                            hint: 'Enter state',
                            controller: stateController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    addressField(
                      label: 'PIN Code',
                      hint: 'Enter 6-digit PIN',
                      controller: pinController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        
                          onPressed: _saveAddress,
                        
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],

        // Keep your existing Column content here
      ),
    ),
  ),
);

    
  }
}
