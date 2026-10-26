
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> deliveryAddress;
  final double subtotal;
  final double deliveryCharge;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'deliveryAddress': deliveryAddress,
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
