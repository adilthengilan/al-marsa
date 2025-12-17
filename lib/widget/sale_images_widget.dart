import 'package:daily_sales/controller/branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:daily_sales/model/sale_models.dart';

class SaleImagesWidget extends StatelessWidget {
  final Branch_Sale sale;

  const SaleImagesWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    if (sale.billImages.isEmpty) {
      return const Text("No Bill Images");
    }

    final _service = BranchService();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sale.billImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final url = sale.billImages[index];

        return Stack(
          children: [
            // Open image in full screen
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(
                      child: Image.network(url),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url, fit: BoxFit.cover),
              ),
            ),

            // Delete button
            Positioned(
              right: 4,
              top: 4,
              child: InkWell(
                onTap: () async {
                  await _service.deleteBillImage(sale.id, url);

                  // NO setState needed! StreamBuilder will refresh automatically

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Image deleted")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
