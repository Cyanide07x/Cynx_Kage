class CouponModel {
  final int id;
  final String code;
  final String discountType; // 'percentage' | 'fixed'
  final double discountValue;
  final double minSubtotal;
  final double? maxDiscount;
  final String description;
  final DateTime? expiresAt;
  final int? maxUses;
  final int usedCount;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minSubtotal = 0.0,
    this.maxDiscount,
    required this.description,
    this.expiresAt,
    this.maxUses,
    this.usedCount = 0,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedExpiry;
    final rawExpiry = json['expires_at'] ?? json['expiresAt'];
    if (rawExpiry is String) {
      parsedExpiry = DateTime.tryParse(rawExpiry);
    }

    return CouponModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] ?? '').toString().toUpperCase(),
      discountType: (json['discount_type'] ?? json['discountType'] ?? 'percentage').toString(),
      discountValue: ((json['discount_value'] ?? json['discountValue']) as num?)?.toDouble() ?? 0.0,
      minSubtotal: ((json['min_subtotal'] ?? json['minSubtotal']) as num?)?.toDouble() ?? 0.0,
      maxDiscount: ((json['max_discount'] ?? json['maxDiscount']) as num?)?.toDouble(),
      description: (json['description'] ?? '').toString(),
      expiresAt: parsedExpiry,
      maxUses: (json['max_uses'] ?? json['maxUses'] as num?)?.toInt(),
      usedCount: (json['used_count'] ?? json['usedCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get discountBadgeText {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}%';
    }
    return '₹${discountValue.toInt()}';
  }
}
