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
  final String? couponCode;
  final double discountAmount;
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
    this.couponCode,
    this.discountAmount = 0.0,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['createdAt'] ?? json['created_at'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawItems = json['items'];
    final itemsList = rawItems is List
        ? rawItems.map((it) => Map<String, dynamic>.from(it as Map)).toList()
        : <Map<String, dynamic>>[];

    final rawAddress = json['deliveryAddress'] ?? json['delivery_address'];
    final addressMap = rawAddress is Map
        ? Map<String, dynamic>.from(rawAddress)
        : <String, dynamic>{};

    return OrderModel(
      orderId: (json['order_number'] ?? json['orderNumber'] ?? json['order_id'] ?? json['orderId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      items: itemsList,
      deliveryAddress: addressMap,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] ?? json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] ?? json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? 'COD').toString(),
      paymentStatus: (json['paymentStatus'] ?? json['payment_status'] ?? 'pending').toString(),
      orderStatus: (json['orderStatus'] ?? json['order_status'] ?? 'pending').toString(),
      couponCode: json['couponCode']?.toString() ?? json['coupon_code']?.toString(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items,
      'deliveryAddress': deliveryAddress,
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      if (couponCode != null) 'couponCode': couponCode,
      'discountAmount': discountAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
