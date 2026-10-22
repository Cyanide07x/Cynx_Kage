import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_item.dart';

class CartService {
  CartService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Each signed-in user has their own cart.
  CollectionReference<Map<String, dynamic>> get _cartCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to access your cart.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');
  }

  // The same product, size, and color always map to the same document.
  String _documentId(CartItem item) {
    final key = jsonEncode([
      item.productId,
      item.size,
      item.color,
    ]);

    return base64Url.encode(utf8.encode(key)).replaceAll('=', '');
  }

  // Load all saved cart items for the current user.
  Future<List<CartItem>> loadCart() async {
    final snapshot = await _cartCollection.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return CartItem(
        productId: (data['productId'] ?? '').toString(),
        name: (data['name'] ?? 'Product').toString(),
        imageUrl: (data['imageUrl'] ?? '').toString(),
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        size: (data['size'] ?? '').toString(),
        color: (data['color'] ?? 'Default').toString(),
        quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();
  }

  // Add an item or increase the quantity of an existing variation.
  Future<void> addItem(CartItem item) async {
    final doc = _cartCollection.doc(_documentId(item));

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final currentQuantity =
            (data['quantity'] as num?)?.toInt() ?? 1;

        transaction.update(doc, {
          'quantity': currentQuantity + item.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(doc, {
          'productId': item.productId,
          'name': item.name,
          'imageUrl': item.imageUrl,
          'price': item.price,
          'size': item.size,
          'color': item.color,
          'quantity': item.quantity,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Set an item's quantity.
  Future<void> updateQuantity(
    CartItem item,
    int quantity,
  ) async {
    if (quantity < 1) {
      throw ArgumentError('Quantity must be at least 1.');
    }

    await _cartCollection.doc(_documentId(item)).update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove a specific product variation.
  Future<void> removeItem(CartItem item) async {
    await _cartCollection.doc(_documentId(item)).delete();
  }

  // Clear the current user's cart.
  Future<void> clearCart() async {
    final collection = _cartCollection;
    final snapshot = await collection.get();

    // Firestore batches support at most 500 writes.
    for (var start = 0; start < snapshot.docs.length; start += 500) {
      final batch = _firestore.batch();
      final end = (start + 500 < snapshot.docs.length)
          ? start + 500
          : snapshot.docs.length;

      for (final doc in snapshot.docs.sublist(start, end)) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }
}