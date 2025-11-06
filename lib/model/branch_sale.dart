import 'package:cloud_firestore/cloud_firestore.dart';

class Branch_Sale {
  final String id;
  final String shopId;
  final String productName;
  final double amount;
  final DateTime date;
  final String paymentMethod; // 'cash' or 'bank'
  final bool isPaid;
  final double? paidAmount; // NEW FIELD - tracks partial payments

  Branch_Sale({
    required this.id,
    required this.shopId,
    required this.productName,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.isPaid = true,
    this.paidAmount = 0.0, // Default to 0
  });

  factory Branch_Sale.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Branch_Sale(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      productName: data['productName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      isPaid: data['isPaid'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shopId': shopId,
      'productName': productName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
    };
  }
}
