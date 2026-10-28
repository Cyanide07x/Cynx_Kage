
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';
import '../../screens/cart/cart_item.dart';
import '../../screens/address/saved_address.dart';

class OrderService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<String> createOrder({
    required List<CartItem> cartItems,
    required SavedAddress address,
    required double subtotal,
    required double deliveryCharge,
    required double totalAmount,
    required String paymentMethod,
    String? couponCode,
    double discountAmount = 0.0,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in before placing an order.');
    }

    if (cartItems.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    if (paymentMethod != 'COD' &&
        paymentMethod != 'UPI' &&
        paymentMethod != 'CARD') {
      throw Exception('Please select a valid payment method.');
    }

    final orderRef = _firestore.collection('orders').doc();

    final order = OrderModel(
      orderId: orderRef.id,
      userId: user.uid,
      items: cartItems.map((item) {
        return {
          'productId': item.productId,
          'name': item.name,
          'imageUrl': item.imageUrl,
          'price': item.price,
          'quantity': item.quantity,
          'size': item.size,
          'color': item.color,
          'totalPrice': item.totalPrice,
        };
      }).toList(),
      deliveryAddress: {
        'name': address.name,
        'phone': address.phone,
        'address': address.address,
        'city': address.city,
        'state': address.state,
        'pin': address.pin,
      },
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus:
          paymentMethod == 'COD' ? 'pending' : 'pending_payment',
      orderStatus:
          paymentMethod == 'COD' ? 'placed' : 'pending_payment',
      couponCode: couponCode,
      discountAmount: discountAmount,
      createdAt: DateTime.now(),
    );

    await orderRef.set({
      ...order.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return orderRef.id;
  }
}
