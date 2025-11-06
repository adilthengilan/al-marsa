// Models
import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  final String id;
  final String name;
  final String location;
  final String phone;
  final DateTime createdAt;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.createdAt,
  });

  factory Branch.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Branch(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
