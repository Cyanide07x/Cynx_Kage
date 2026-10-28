import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Please sign in to apply a coupon.');
    }

    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw Exception('Please enter a valid coupon code.');
    }

    final docSnapshot =
        await _firestore.collection('coupons').doc(normalizedCode).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw Exception('This coupon does not exist.');
    }

    final data = docSnapshot.data()!;

    final isActive = data['isActive'] == true;
    if (!isActive) {
      throw Exception('This coupon is inactive.');
    }

    final expiresAtRaw = data['expiresAt'];
    if (expiresAtRaw is Timestamp) {
      if (expiresAtRaw.toDate().isBefore(DateTime.now())) {
        throw Exception('This coupon has expired.');
      }
    }

    final maxUses = (data['maxUses'] as num?)?.toInt();
    final usedCount = (data['usedCount'] as num?)?.toInt() ?? 0;
    if (maxUses != null && usedCount >= maxUses) {
      throw Exception('This coupon has reached its usage limit.');
    }

    final minSubtotal = (data['minSubtotal'] as num?)?.toDouble() ?? 0.0;
    if (subtotal < minSubtotal) {
      throw Exception(
        'Your cart subtotal must be at least ₹${minSubtotal.toStringAsFixed(0)}.',
      );
    }

    final discountType = data['discountType'] as String? ?? 'percentage';
    final discountValue = ((data['discountValue'] ?? data['discounValue']) as num?)?.toDouble() ?? 0.0;
    if (discountValue <= 0) {
      throw Exception('This coupon has an invalid discount.');
    }

    double discount = 0.0;
    if (discountType == 'percentage') {
      discount = (subtotal * discountValue) / 100;
      final maxDiscount = (data['maxDiscount'] as num?)?.toDouble();
      if (maxDiscount != null && maxDiscount > 0 && discount > maxDiscount) {
        discount = maxDiscount;
      }
    } else if (discountType == 'fixed') {
      discount = discountValue;
    } else {
      throw Exception('Unsupported discount type.');
    }

    if (discount > subtotal) {
      discount = subtotal;
    }

    discount = (discount * 100).round() / 100;

    return {
      'valid': true,
      'code': normalizedCode,
      'discountType': discountType,
      'discountValue': discountValue,
      'discountAmount': discount,
      'finalSubtotal': subtotal - discount,
      'message': 'Coupon applied successfully.',
    };
  }
}
