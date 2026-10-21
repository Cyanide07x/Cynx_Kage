import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'wishlist_item.dart';

class WishlistService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WishlistService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _wishlistCollection(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist');
  }

  String _requireUserId() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to use your wishlist.');
    }

    return user.uid;
  }

  Stream<List<WishlistItem>> watchWishlist() {
    final uid = _requireUserId();

    return _wishlistCollection(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WishlistItem.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<bool> toggleItem(WishlistItem item) async {
    final uid = _requireUserId();
    final reference = _wishlistCollection(uid).doc(item.productId);

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(reference);

      if (snapshot.exists) {
        transaction.delete(reference);
        return false;
      }

      transaction.set(reference, {
        ...item.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  Future<void> removeItem(String productId) async {
    final uid = _requireUserId();

    await _wishlistCollection(uid).doc(productId).delete();
  }
}