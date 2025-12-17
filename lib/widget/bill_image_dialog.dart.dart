import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_sales/model/sale_models.dart';
import 'package:daily_sales/widget/sale_images_widget.dart';
import 'package:flutter/material.dart';

void showBillImagesDialog(BuildContext context, String saleId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Bill Images", style: TextStyle(color: Colors.blue[700])),

        content: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sales')
              .doc(saleId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Text("No bill images found");
            }

            final doc = snapshot.data!;
            final updatedSale = Branch_Sale.fromFirestore(doc);

            if (updatedSale.billImages.isEmpty) {
              return Text("No images uploaded");
            }

            return SizedBox(
              width: 300,
              height: 300,
              child: SaleImagesWidget(sale: updatedSale),
            );
          },
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}
