class SavedAddress {
  final int? addressId;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pin;
  final bool isDefault;
  final String addressType;

  const SavedAddress({
    this.addressId,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pin,
    this.isDefault = false,
    this.addressType = 'home',
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      addressId: json['address_id'] as int?,
      name: (json['recipient_name'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address_line1'] ?? json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      pin: (json['postal_code'] ?? json['pin'] ?? '').toString(),
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      addressType: (json['address_type'] ?? 'home').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) 'address_id': addressId,
      'name': name,
      'recipient_name': name,
      'phone': phone,
      'address': address,
      'address_line1': address,
      'city': city,
      'state': state,
      'pin': pin,
      'postal_code': pin,
      'is_default': isDefault,
      'address_type': addressType,
    };
  }

  SavedAddress copyWith({
    int? addressId,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pin,
    bool? isDefault,
    String? addressType,
  }) {
    return SavedAddress(
      addressId: addressId ?? this.addressId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pin: pin ?? this.pin,
      isDefault: isDefault ?? this.isDefault,
      addressType: addressType ?? this.addressType,
    );
  }
}
