import 'package:cloud_firestore/cloud_firestore.dart';

class OrderData {
  final String documentId;
  final String name;
  final String address;
  String status;
  final String productID;
  final String productName;
  final double totalPrice;
  final Timestamp timestamp;
  final String paymentMethod;

  OrderData({
    required this.documentId,
    required this.name,
    required this.address,
    required this.status,
    required this.productID,
    required this.productName,
    required this.totalPrice,
    required this.timestamp,
    required this.paymentMethod,
  });

  factory OrderData.fromMap(String documentId, Map<String, dynamic> map) {
    return OrderData(
      documentId: documentId,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? '',
      productID: map['productID']?.toString() ?? '',
      productName: map['productName'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] ?? Timestamp(0, 0),
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }
}
