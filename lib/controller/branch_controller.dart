// Firestore Service
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_sales/model/branch.dart';
import 'package:daily_sales/model/sale_models.dart';
import 'package:daily_sales/model/shop_models.dart';

class BranchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Shop CRUD Operations
  Future<void> addBranch(Branch shop) async {
    await _db.collection('branches').add(shop.toFirestore());
  }

  Future<void> updateShop(Shop shop) async {
    await _db.collection('branches').doc(shop.id).update(shop.toFirestore());
  }

  Future<void> deleteShop(String shopId) async {
    // Delete all sales for this shop first
    final salesQuery = await _db
        .collection('branchSales')
        .where('shopId', isEqualTo: shopId)
        .get();

    for (var doc in salesQuery.docs) {
      await doc.reference.delete();
    }

    // Then delete the shop
    await _db.collection('branches').doc(shopId).delete();
  }

  Stream<List<Branch>> getShops() {
    return _db
        .collection('branches')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Branch.fromFirestore(doc)).toList(),
        );
  }

  // Sale CRUD Operations
  Future<void> addSale(Branch_Sale sale) async {
    await _db.collection('branchSales').add(sale.toFirestore());
  }

  Future<void> updateSale(Branch_Sale sale) async {
    await _db.collection('branchSales').doc(sale.id).update(sale.toFirestore());
  }

  Future<void> deleteSale(String saleId) async {
    await _db.collection('branchSales').doc(saleId).delete();
  }

  Stream<List<Branch_Sale>> getSalesForShop(String shopId) {
    return FirebaseFirestore.instance
        .collection('branchSales')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Branch_Sale.fromFirestore(
              doc,
            ); // ensure this handles nulls safely
          }).toList();
        });
  }

  // Statistics
  Future<Map<String, double>> getShopStats(String shopId) async {
    final salesSnapshot = await _db
        .collection('branchSales')
        .where('shopId', isEqualTo: shopId)
        .get();

    double totalSales = 0;
    double collectedAmount = 0;
    double dueAmount = 0;
    double cashAmount = 0; // NEW - Total cash received
    double bankAmount = 0; // NEW - Total bank received

    for (var doc in salesSnapshot.docs) {
      final sale = Branch_Sale.fromFirestore(doc);
      totalSales += sale.amount;

      if (sale.isPaid) {
        collectedAmount += sale.amount;

        // Track by payment method - only for PAID sales
        if (sale.paymentMethod == 'cash') {
          cashAmount += sale.amount;
        } else if (sale.paymentMethod == 'bank') {
          bankAmount += sale.amount;
        }
      } else {
        dueAmount += sale.amount;
      }
    }

    return {
      'totalSales': totalSales,
      'collectedAmount': collectedAmount,
      'dueAmount': dueAmount,
      'cashAmount': cashAmount, // NEW
      'bankAmount': bankAmount, // NEW
    };
  }
}

// Future<Map<String, double>> getShopStats(String shopId) async {
//   // Get current month's start and end dates
//   final now = DateTime.now();
//   final startOfMonth = DateTime(now.year, now.month, 1);
//   final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

//   final salesSnapshot = await _db
//       .collection('sales')
//       .where('shopId', isEqualTo: shopId)
//       .where('date', isGreaterThanOrEqualTo: startOfMonth)
//       .where('date', isLessThanOrEqualTo: endOfMonth)
//       .get();

//   double totalSales = 0;
//   double collectedAmount = 0;
//   double dueAmount = 0;
//   double cashAmount = 0;      // NEW - Total cash received
//   double bankAmount = 0;      // NEW - Total bank received

//   for (var doc in salesSnapshot.docs) {
//     final sale = Sale.fromFirestore(doc);
//     totalSales += sale.amount;
    
//     if (sale.isPaid) {
//       collectedAmount += sale.amount;
      
//       // Track by payment method - only for PAID sales
//       if (sale.paymentMethod == 'cash') {
//         cashAmount += sale.amount;
//       } else if (sale.paymentMethod == 'bank') {
//         bankAmount += sale.amount;
//       }
//     } else {
//       dueAmount += sale.amount;
//     }
//   }

//   return {
//     'totalSales': totalSales,
//     'collectedAmount': collectedAmount,
//     'dueAmount': dueAmount,
//     'cashAmount': cashAmount,      // NEW
//     'bankAmount': bankAmount,      // NEW
//   };
// }

// // If your Sale model has a paidAmount field for partial payments, use this version:
// Future<Map<String, double>> getShopStatsWithPartialPayments(String shopId) async {
//   // Get current month's start and end dates
//   final now = DateTime.now();
//   final startOfMonth = DateTime(now.year, now.month, 1);
//   final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

//   final salesSnapshot = await _db
//       .collection('sales')
//       .where('shopId', isEqualTo: shopId)
//       .where('date', isGreaterThanOrEqualTo: startOfMonth)
//       .where('date', isLessThanOrEqualTo: endOfMonth)
//       .get();

//   double totalSales = 0;
//   double collectedAmount = 0;
//   double dueAmount = 0;
//   double cashAmount = 0;
//   double bankAmount = 0;

//   for (var doc in salesSnapshot.docs) {
//     final sale = Sale.fromFirestore(doc);
//     totalSales += sale.amount;
    
//     // Calculate how much has been paid (handles partial payments)
//     double paidAmount = 0;
//     if (sale.isPaid) {
//       paidAmount = sale.amount; // Fully paid
//     } else if (sale.paidAmount != null && sale.paidAmount! > 0) {
//       paidAmount = sale.paidAmount!; // Partial payment
//     }
    
//     collectedAmount += paidAmount;
//     dueAmount += (sale.amount - paidAmount);
    
//     // Track by payment method - count the PAID portion only
//     if (paidAmount > 0) {
//       if (sale.paymentMethod == 'cash') {
//         cashAmount += paidAmount;
//       } else if (sale.paymentMethod == 'bank') {
//         bankAmount += paidAmount;
//       }
//     }
//   }

//   return {
//     'totalSales': totalSales,
//     'collectedAmount': collectedAmount,
//     'dueAmount': dueAmount,
//     'cashAmount': cashAmount,
//     'bankAmount': bankAmount,
//   };
// }