import 'package:daily_sales/controller/shop_services.dart';
import 'package:daily_sales/model/shop_models.dart';
import 'package:daily_sales/view/Shop_Details/sales_page.dart';
import 'package:flutter/material.dart';

// Main Shops Page
class shops_page extends StatefulWidget {
  const shops_page({super.key});

  @override
  State<shops_page> createState() => _shops_pageState();
}

class _shops_pageState extends State<shops_page> {
  final BranchService _shopService = BranchService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shop Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your stores & sales',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add_business,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => _showAddShopDialog(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search shops by name or location...',
                        prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Shops List
            Expanded(
              child: StreamBuilder<List<Shop>>(
                stream: _shopService.getShops(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.blue[700]),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final shops = snapshot.data!.where((shop) {
                    if (_searchQuery.isEmpty) return true;
                    return shop.name.toLowerCase().contains(_searchQuery) ||
                        shop.location.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (shops.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No shops found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      return _buildShopCard(context, shops[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_mall_directory,
              size: 80,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Shops Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first shop to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddShopDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Shop shop) {
    return FutureBuilder<Map<String, double>>(
      future: _shopService.getShopStats(shop.id),
      builder: (context, statsSnapshot) {
        final stats =
            statsSnapshot.data ??
            {
              'totalSales': 0,
              'collectedAmount': 0,
              'dueAmount': 0,
              'cashAmount': 0, // NEW
              'bankAmount': 0, // NEW
            };

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesPage(shop: shop),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[700]!, Colors.blue[500]!],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: const Color.fromARGB(160, 13, 72, 161),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      shop.location,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    shop.phone,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.grey[700],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_rounded, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () => _showEditShopDialog(context, shop),
                                );
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.delete_rounded, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () => _confirmDeleteShop(context, shop),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Main Stats Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 32, 141, 231),
                            Color(0xFF1976D2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMainStatItem(
                              'Total Sales',
                              'AED ${stats['totalSales']!.toStringAsFixed(2)}',
                              Icons.trending_up_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildMainStatItem(
                              'Collected',
                              'AED ${stats['collectedAmount']!.toStringAsFixed(2)}',
                              Icons.check_circle_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildMainStatItem(
                              'Due',
                              'AED ${stats['dueAmount']!.toStringAsFixed(2)}',
                              Icons.pending_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Payment Methods Section
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.payments_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cash',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'AED ${stats['cashAmount']!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bank',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'AED ${stats['bankAmount']!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Update your ShopService getShopStats method to include cash and bank amounts:
  /*
Future<Map<String, double>> getShopStats(String shopId) async {
  try {
    final sales = await FirebaseFirestore.instance
        .collection('sales')
        .where('shopId', isEqualTo: shopId)
        .get();

    double totalSales = 0;
    double collectedAmount = 0;
    double dueAmount = 0;
    double cashAmount = 0;
    double bankAmount = 0;

    for (var doc in sales.docs) {
      final sale = Sale.fromFirestore(doc);
      totalSales += sale.price;

      // Calculate paid amount (handles partial payments)
      double paidAmount = sale.paidAmount ?? 0;
      
      if (sale.paymentStatus == 'paid') {
        paidAmount = sale.price; // Fully paid
      }

      collectedAmount += paidAmount;
      dueAmount += (sale.price - paidAmount);

      // Track by payment method (only count the PAID portion)
      if (paidAmount > 0) {
        if (sale.paymentMethod == 'cash') {
          cashAmount += paidAmount;
        } else if (sale.paymentMethod == 'bank') {
          bankAmount += paidAmount;
        }
      }
    }

    return {
      'totalSales': totalSales,
      'collectedAmount': collectedAmount,
      'dueAmount': dueAmount,
      'cashAmount': cashAmount,
      'bankAmount': bankAmount,
    };
  } catch (e) {
    print('Error getting shop stats: $e');
    return {
      'totalSales': 0,
      'collectedAmount': 0,
      'dueAmount': 0,
      'cashAmount': 0,
      'bankAmount': 0,
    };
  }
}
*/

  // Widget _buildMainStatItem(String label, String value, IconData icon) {
  //   return Column(
  //     children: [
  //       Icon(icon, color: Colors.white, size: 24),
  //       const SizedBox(height: 8),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 11,
  //           color: Colors.white.withOpacity(0.9),
  //           fontWeight: FontWeight.w600,
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         value,
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w900,
  //           color: Colors.white,
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //     ],
  //   );
  // }

  // Update your ShopService getShopStats method to include cash and bank amounts:
  /*
Future<Map<String, double>> getShopStats(String shopId) async {
  try {
    final sales = await FirebaseFirestore.instance
        .collection('sales')
        .where('shopId', isEqualTo: shopId)
        .get();

    double totalSales = 0;
    double collectedAmount = 0;
    double dueAmount = 0;
    double cashAmount = 0;      // NEW
    double bankAmount = 0;      // NEW

    for (var doc in sales.docs) {
      final sale = Sale.fromFirestore(doc);
      totalSales += sale.price;

      if (sale.paymentStatus == 'paid') {
        collectedAmount += sale.price;
        
        // Track by payment method
        if (sale.paymentMethod == 'cash') {
          cashAmount += sale.price;
        } else if (sale.paymentMethod == 'bank') {
          bankAmount += sale.price;
        }
      } else {
        dueAmount += sale.price;
      }
    }

    return {
      'totalSales': totalSales,
      'collectedAmount': collectedAmount,
      'dueAmount': dueAmount,
      'cashAmount': cashAmount,      // NEW
      'bankAmount': bankAmount,      // NEW
    };
  } catch (e) {
    print('Error getting shop stats: $e');
    return {
      'totalSales': 0,
      'collectedAmount': 0,
      'dueAmount': 0,
      'cashAmount': 0,
      'bankAmount': 0,
    };
  }
}
*/

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAddShopDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.store, color: Colors.blue[700]),
            ),
            const SizedBox(width: 12),
            const Text('Add New Shop'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: const Icon(Icons.business, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on,color:  Colors.blue,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone,color:  Colors.blue,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final shop = Shop(
                  id: '',
                  name: nameController.text,
                  location: locationController.text,
                  phone: phoneController.text,
                  createdAt: DateTime.now(),
                );
                await _shopService.addShop(shop);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add Shop'),
          ),
        ],
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, Shop shop) {
    final nameController = TextEditingController(text: shop.name);
    final locationController = TextEditingController(text: shop.location);
    final phoneController = TextEditingController(text: shop.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Shop'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: const Icon(Icons.business,color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on,color: Colors.blue,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone,color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedShop = Shop(
                  id: shop.id,
                  name: nameController.text,
                  location: locationController.text,
                  phone: phoneController.text,
                  createdAt: shop.createdAt,
                );
                await _shopService.updateShop(updatedShop);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShop(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Shop'),
        content: Text(
          'Are you sure you want to delete "${shop.name}"? This will also delete all associated sales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _shopService.deleteShop(shop.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}




////////////////////////////////////////////////////
 
  

 

  

  
// Widget _buildEmptyState(BuildContext context, Shop shop) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(30),
//           decoration: BoxDecoration(
//             color: Colors.blue[50],
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.receipt_long, size: 80, color: Colors.blue[300]),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           'No Sales Yet',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Add your first sale to track revenue',
//           style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//         ),
//         const SizedBox(height: 24),
//         ElevatedButton.icon(
//           onPressed: () => _showAddSaleDialog(context, shop),
//           icon: const Icon(Icons.add),
//           label: const Text('Add Sale'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue[700],
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildSaleCard(BuildContext context, Sale sale) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 16),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [Colors.white, Colors.blue[50]!],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.blue.withOpacity(0.15),
//           blurRadius: 15,
//           offset: const Offset(0, 5),
//         ),
//       ],
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: sale.isPaid
//                         ? [Colors.green[600]!, Colors.green[400]!]
//                         : [Colors.orange[600]!, Colors.orange[400]!],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: (sale.isPaid ? Colors.green : Colors.orange)
//                           .withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   sale.isPaid ? Icons.check_circle : Icons.pending,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       sale.productName,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           sale.paymentMethod == 'cash'
//                               ? Icons.money
//                               : Icons.account_balance,
//                           size: 16,
//                           color: Colors.grey[600],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           sale.paymentMethod.toUpperCase(),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Icon(
//                           Icons.calendar_today,
//                           size: 14,
//                           color: Colors.grey[600],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           DateFormat('MMM dd, yyyy').format(sale.date),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '\${sale.amount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[700],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: sale.isPaid
//                           ? Colors.green[100]
//                           : Colors.orange[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       sale.isPaid ? 'PAID' : 'DUE',
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: sale.isPaid
//                             ? Colors.green[700]
//                             : Colors.orange[700],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 8),
//               PopupMenuButton(
//                 icon: Icon(Icons.more_vert, color: Colors.grey[700]),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     child: const Row(
//                       children: [
//                         Icon(Icons.edit, color: Colors.blue),
//                         SizedBox(width: 8),
//                         Text('Edit'),
//                       ],
//                     ),
//                     onTap: () {
//                       Future.delayed(
//                         const Duration(milliseconds: 100),
//                         () => _showEditSaleDialog(context, sale),
//                       );
//                     },
//                   ),
//                   PopupMenuItem(
//                     child: Row(
//                       children: [
//                         Icon(
//                           sale.isPaid ? Icons.cancel : Icons.check_circle,
//                           color: sale.isPaid ? Colors.orange : Colors.green,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(sale.isPaid ? 'Mark as Due' : 'Mark as Paid'),
//                       ],
//                     ),
//                     onTap: () {
//                       Future.delayed(
//                         const Duration(milliseconds: 100),
//                         () => _togglePaymentStatus(sale),
//                       );
//                     },
//                   ),
//                   PopupMenuItem(
//                     child: const Row(
//                       children: [
//                         Icon(Icons.delete, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text('Delete'),
//                       ],
//                     ),
//                     onTap: () {
//                       Future.delayed(
//                         const Duration(milliseconds: 100),
//                         () => _confirmDeleteSale(context, sale),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }



// Add this method to your _SalesPageState class

// void _showEditSaleDialog(BuildContext context, Sale sale) {
//   final TextEditingController amountController = TextEditingController();
//   String selectedPaymentStatus = sale.isPaid.toString();
//   String selectedPaymentMethod = sale.paymentMethod;
//   double remainingAmount = sale.amount - (sale.paidAmount ?? 0);

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Container(
//               constraints: BoxConstraints(maxWidth: 500),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Colors.white, Color(0xFFE3F2FD)],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Icon(
//                               Icons.edit_rounded,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Edit Sale',
//                                   style: TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w900,
//                                     color: Colors.blue[900],
//                                   ),
//                                 ),
//                                 Text(
//                                   sale.productName,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[600],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               Icons.close_rounded,
//                               color: Colors.grey[600],
//                             ),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 24),

//                       // Amount Summary Card
//                       Container(
//                         padding: EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.blue.withOpacity(0.3),
//                               blurRadius: 12,
//                               offset: Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Total Amount',
//                                       style: TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       'AED ${sale.amount.toStringAsFixed(2)}',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.w900,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Container(
//                                   padding: EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Icon(
//                                     Icons.attach_money_rounded,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildAmountInfoItem(
//                                     'Paid',
//                                     'AED ${(sale.paidAmount ?? 0).toStringAsFixed(2)}',
//                                     Icons.check_circle_rounded,
//                                     Colors.green,
//                                   ),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: _buildAmountInfoItem(
//                                     'Remaining',
//                                     'AED ${remainingAmount.toStringAsFixed(2)}',
//                                     Icons.pending_rounded,
//                                     Colors.orange,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 24),

//                       // Payment Status Section
//                       Text(
//                         'Payment Status',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.blue[900],
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildStatusButton(
//                               'Paid',
//                               Icons.check_circle_rounded,
//                               selectedPaymentStatus == 'paid',
//                               Color(0xFF4CAF50),
//                               () {
//                                 setState(() {
//                                   selectedPaymentStatus = 'paid';
//                                 });
//                               },
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: _buildStatusButton(
//                               'Due',
//                               Icons.pending_rounded,
//                               selectedPaymentStatus == 'due',
//                               Color(0xFFFF9800),
//                               () {
//                                 setState(() {
//                                   selectedPaymentStatus = 'due';
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 24),

//                       // Payment Method Section
//                       Text(
//                         'Payment Method',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.blue[900],
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildMethodButton(
//                               'Cash',
//                               Icons.payments_rounded,
//                               selectedPaymentMethod == 'cash',
//                               () {
//                                 setState(() {
//                                   selectedPaymentMethod = 'cash';
//                                 });
//                               },
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: _buildMethodButton(
//                               'Bank',
//                               Icons.account_balance_rounded,
//                               selectedPaymentMethod == 'bank',
//                               () {
//                                 setState(() {
//                                   selectedPaymentMethod = 'bank';
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 24),

//                       // Add Payment Section (only show if status is due)
//                       if (selectedPaymentStatus == 'due' &&
//                           remainingAmount > 0) ...[
//                         Container(
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.orange[50],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.orange[200]!,
//                               width: 1,
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.add_card_rounded,
//                                     color: Colors.orange[700],
//                                     size: 20,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Add Partial Payment',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.orange[900],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 12),
//                               TextField(
//                                 controller: amountController,
//                                 keyboardType: TextInputType.numberWithOptions(
//                                   decimal: true,
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'Amount Received',
//                                   labelStyle: TextStyle(
//                                     color: Colors.orange[700],
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   prefixIcon: Icon(
//                                     Icons.attach_money_rounded,
//                                     color: Colors.orange[700],
//                                   ),
//                                   suffixText: 'AED',
//                                   suffixStyle: TextStyle(
//                                     color: Colors.orange[700],
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                       color: Colors.orange[300]!,
//                                     ),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                       color: Colors.orange[300]!,
//                                     ),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                       color: Colors.orange[700]!,
//                                       width: 2,
//                                     ),
//                                   ),
//                                 ),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.blue[900],
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Max: AED ${remainingAmount.toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 24),
//                       ],

//                       // Action Buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: () => Navigator.pop(context),
//                               style: OutlinedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(vertical: 16),
//                                 side: BorderSide(
//                                   color: Colors.grey[400]!,
//                                   width: 2,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Cancel',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             flex: 2,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Color(0xFF2196F3),
//                                     Color(0xFF1976D2),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.blue.withOpacity(0.4),
//                                     blurRadius: 12,
//                                     offset: Offset(0, 6),
//                                   ),
//                                 ],
//                               ),
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   _updateSale(
//                                     sale,
//                                     selectedPaymentStatus,
//                                     selectedPaymentMethod,
//                                     amountController.text,
//                                     context,
//                                   );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.transparent,
//                                   shadowColor: Colors.transparent,
//                                   padding: EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.save_rounded, size: 20),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Update Sale',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }



// Update your Sale model to include paidAmount field:
/*
class Sale {
  final String id;
  final String productName;
  final double price;
  final String paymentStatus; // 'paid' or 'due'
  final String paymentMethod; // 'cash' or 'bank'
  final DateTime date;
  final double? paidAmount; // NEW FIELD - tracks partial payments

  Sale({
    required this.id,
    required this.productName,
    required this.price,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.date,
    this.paidAmount = 0.0, // Default to 0
  });
}
*/

// Add this method to your ShopService class:
/*
Future<void> updateSale({
  required String saleId,
  required String paymentStatus,
  required String paymentMethod,
  required double paidAmount,
}) async {
  // Your Firestore/Database update logic
  await FirebaseFirestore.instance
      .collection('sales')
      .doc(saleId)
      .update({
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'paidAmount': paidAmount,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
*/

// Update the _buildSaleCard to add onTap:
/*
Widget _buildSaleCard(Sale sale, int index) {
  // ... existing code ...
  
  return TweenAnimationBuilder(
    // ... existing animation code ...
    child: GestureDetector(
      onTap: () => _showEditSaleDialog(context, sale), // ADD THIS
      child: Container(
        // ... existing container code ...
      ),
    ),
  );
}
*/
