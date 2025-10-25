import 'package:daily_sales/controller/shop_services.dart';
import 'package:daily_sales/model/sale_models.dart';
import 'package:daily_sales/model/shop_models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Main Shops Page
class shops_page extends StatefulWidget {
  const shops_page({super.key});

  @override
  State<shops_page> createState() => _shops_pageState();
}

class _shops_pageState extends State<shops_page> {
  final ShopService _shopService = ShopService();
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
            {'totalSales': 0, 'collectedAmount': 0, 'dueAmount': 0};

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
                            Icons.store,
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
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      shop.location,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    shop.phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
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
                                  Icon(Icons.delete, color: Colors.red),
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Sales',
                            'AED ${stats['totalSales']!.toStringAsFixed(2)}',
                            Icons.trending_up,
                            Colors.blue[700]!,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                            'Collected',
                            'AED ${stats['collectedAmount']!.toStringAsFixed(2)}',
                            Icons.check_circle,
                            Colors.green[600]!,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                            'Due',
                            'AED ${stats['dueAmount']!.toStringAsFixed(2)}',
                            Icons.pending,
                            Colors.orange[700]!,
                          ),
                        ],
                      ),
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
                  prefixIcon: const Icon(Icons.business),
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
                  prefixIcon: const Icon(Icons.location_on),
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
                  prefixIcon: const Icon(Icons.phone),
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
                  prefixIcon: const Icon(Icons.business),
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
                  prefixIcon: const Icon(Icons.location_on),
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
                  prefixIcon: const Icon(Icons.phone),
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

// Sales Page

class SalesPage extends StatefulWidget {
  final Shop shop;

  const SalesPage({super.key, required this.shop});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
    with SingleTickerProviderStateMixin {
  final ShopService _shopService = ShopService();
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _paymentFilter = 'all'; // 'all', 'paid', 'due'
  String _sortOrder = 'newest';
  final _tabcontroller = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildDailySales(), _buildHistorySales()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(widget.shop.id),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shop.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.shop.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.phone_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.shop.phone,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF2196F3),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        padding: EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.today_rounded, size: 18),
                SizedBox(width: 8),
                Text('Today'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 18),
                SizedBox(width: 8),
                Text('History'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySales() {
    return Column(
      children: [
        _buildTodaySummary(),
        const SizedBox(height: 16),
        _buildFilterChips(),
        const SizedBox(height: 16),
        Expanded(child: _buildSalesList(isToday: true)),
      ],
    );
  }

  Widget _buildHistorySales() {
    return Column(
      children: [
        _buildDateSelector(),
        const SizedBox(height: 16),
        _buildFilterChips(),
        const SizedBox(height: 16),
        Expanded(child: _buildSalesList(isToday: false)),
      ],
    );
  }

  Widget _buildTodaySummary() {
    return StreamBuilder<List<Sale>>(
      stream: _shopService.getSalesForShop(widget.shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

        final todaySales = snapshot.data!.where((sale) {
          final saleDate = sale.date;
          final today = DateTime.now();
          return saleDate.year == today.year &&
              saleDate.month == today.month &&
              saleDate.day == today.day;
        }).toList();

        final totalAmount = todaySales.fold<double>(
          0,
          (sum, sale) => sum + sale.amount,
        );
        final paidAmount = todaySales
            .where((sale) => sale.isPaid == true)
            .fold<double>(0, (sum, sale) => sum + sale.amount);
        final dueAmount = todaySales
            .where((sale) => sale.isPaid == false)
            .fold<double>(0, (sum, sale) => sum + sale.amount);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  'AED ${totalAmount.toStringAsFixed(2)}',
                  Icons.receipt_long_rounded,
                  [Color(0xFF2196F3), Color(0xFF1976D2)],
                  '${todaySales.length} items',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Paid',
                  'AED ${paidAmount.toStringAsFixed(2)}',
                  Icons.check_circle_rounded,
                  [Color(0xFF4CAF50), Color(0xFF388E3C)],
                  '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Due',
                  'AED ${dueAmount.toStringAsFixed(2)}',
                  Icons.pending_rounded,
                  [Color(0xFFFF9800), Color(0xFFF57C00)],
                  '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradient,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.blue[700],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Filter:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Paid', 'paid'),
          _buildFilterChip('Due', 'due'),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _sortOrder = _sortOrder == 'newest' ? 'oldest' : 'newest';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    _sortOrder == 'newest'
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _sortOrder == 'newest' ? 'Newest' : 'Oldest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _paymentFilter == value;
    Color chipColor;

    if (value == 'paid') {
      chipColor = Color(0xFF4CAF50);
    } else if (value == 'due') {
      chipColor = Color(0xFFFF9800);
    } else {
      chipColor = Color(0xFF2196F3);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentFilter = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [chipColor, chipColor.withOpacity(0.8)])
              : null,
          color: isSelected ? null : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesList({required bool isToday}) {
    return StreamBuilder<List<Sale>>(
      stream: _shopService.getSalesForShop(widget.shop.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2196F3),
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        }

        var sales = snapshot.data!;

        // Filter by date
        if (isToday) {
          final today = DateTime.now();
          sales = sales.where((sale) {
            return sale.date.year == today.year &&
                sale.date.month == today.month &&
                sale.date.day == today.day;
          }).toList();
        } else {
          sales = sales.where((sale) {
            return sale.date.year == _selectedDate.year &&
                sale.date.month == _selectedDate.month &&
                sale.date.day == _selectedDate.day;
          }).toList();
        }

        // Filter by payment status
        if (_paymentFilter != 'all') {
          sales = sales.where((sale) => sale.isPaid == _paymentFilter).toList();
        }

        // Sort
        if (_sortOrder == 'oldest') {
          sales = sales.reversed.toList();
        }

        if (sales.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            return _buildSaleCard(sales[index], index);
          },
        );
      },
    );
  }

  Widget _buildSaleCard(Sale sale, int index) {
    final isPaid = sale.isPaid == true;
    final statusColor = isPaid ? Color(0xFF4CAF50) : Color(0xFFFF9800);
    final isCash = sale.paymentMethod == 'cash';

    return InkWell(
      onTap: () {
        _showEditSaleDialog(
          context,
          sale.id,
          sale.productName,
          sale.amount,
          sale.date,
          sale.paymentMethod,
          sale.isPaid,
          sale.shopId,
        );
      },
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 300 + (index * 50)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white.withOpacity(0.95)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sale.productName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy • hh:mm a',
                                  ).format(sale.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor,
                                  statusColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              isPaid ? 'PAID' : 'DUE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCash
                                      ? Icons.payments_rounded
                                      : Icons.account_balance_rounded,
                                  color: Color(0xFF2196F3),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Method',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      isCash ? 'Cash' : 'Bank Transfer',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'AED ${sale.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Sales Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding sales to track your business',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load sales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.red[900],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(String shopId) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          _showAddSaleDialog(context, shopId);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(Icons.add_rounded, size: 28, color: Colors.white),
        label: Text(
          'Add Sale',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.blue[900]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // void _showAddSaleDialog(BuildContext context) {
  //   // Your add sale dialog implementation
  //   // This would show a form with fields:
  //   // - Product Name
  //   // - Price
  //   // - Payment Status (Paid/Due)
  //   // - Payment Method (Cash/Bank)
  //   // - Date
  // }
}

// Sample models (adjust according to your actual models)
// class Shop {
//   final String id;
//   final String name;
//   final String location;
//   final String phone;

//   Shop({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.phone,
//   });
// }

// class Sale {
//   final String id;
//   final String productName;
//   final double price;
//   final String paymentStatus; // 'paid' or 'due'
//   final String paymentMethod; // 'cash' or 'bank'
//   final DateTime date;

//   Sale({
//     required this.id,
//     required this.productName,
//     required this.price,
//     required this.paymentStatus,
//     required this.paymentMethod,
//     required this.date,
//   });
// }

// class ShopService {
//   Stream<List<Sale>> getSalesForShop(String shopId) {
//     // Your implementation to fetch sales from database
//     return Stream.value([]);
//   }
// }

// 🔹 Example empty-state builder
Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          'No sales found for this shop',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    ),
  );
}

// 🔹 Example sale card
Widget _buildSaleCard(BuildContext context, Sale sale) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      title: Text(sale.productName),
      subtitle: Text('Amount: AED ${sale.amount}'),
      trailing: Text(
        sale.date.toString().split(' ')[0],
        style: const TextStyle(color: Colors.grey),
      ),
    ),
  );
}

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

void _showAddSaleDialog(BuildContext context, String shopId) {
  Shop shop;
  final productController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String paymentMethod = 'cash';
  bool isPaid = true;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_shopping_cart, color: Colors.blue[700]),
            ),
            const SizedBox(width: 12),
            const Text('Add New Sale'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: productController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: const Icon(Icons.shopping_bag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) {
                      return 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Cash'),
                              value: 'cash',
                              groupValue: paymentMethod,
                              onChanged: (value) {
                                setDialogState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Bank'),
                              value: 'bank',
                              groupValue: paymentMethod,
                              onChanged: (value) {
                                setDialogState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Payment Status'),
                  subtitle: Text(isPaid ? 'Paid' : 'Due'),
                  value: isPaid,
                  onChanged: (value) {
                    setDialogState(() {
                      isPaid = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ],
            ),
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
                final _shopService = ShopService();

                final sale = Sale(
                  id: '',
                  shopId: shopId,
                  productName: productController.text,
                  amount: double.parse(amountController.text),
                  date: selectedDate,
                  paymentMethod: paymentMethod,
                  isPaid: isPaid,
                );
                await _shopService.addSale(sale);
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
            child: const Text('Add Sale'),
          ),
        ],
      ),
    ),
  );
}

void _showEditSaleDialog(
  BuildContext context,
  id,
  name,
  amount,
  date,
  method,
  paid,
  shopId,
) {
  final productController = TextEditingController(text: name);
  final amountController = TextEditingController(text: amount.toString());
  DateTime selectedDate = date;
  String paymentMethod = method;
  bool isPaid = paid;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Sale'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: productController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: const Icon(Icons.shopping_bag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) {
                      return 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Cash'),
                              value: 'cash',
                              groupValue: paymentMethod,
                              onChanged: (value) {
                                setDialogState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Bank'),
                              value: 'bank',
                              groupValue: paymentMethod,
                              onChanged: (value) {
                                setDialogState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Payment Status'),
                  subtitle: Text(isPaid ? 'Paid' : 'Due'),
                  value: isPaid,
                  onChanged: (value) {
                    setDialogState(() {
                      isPaid = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ],
            ),
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
                final updatedSales = Sale(
                  id: id,
                  shopId: shopId,
                  productName: productController.text,
                  amount: double.parse(amountController.text),
                  date: selectedDate,
                  paymentMethod: paymentMethod,
                  isPaid: isPaid,
                );
                final shopService = ShopService();
                await shopService.updateSale(updatedSales);
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
    ),
  );
}

void _togglePaymentStatus(Sale sale) async {
  final updatedSale = Sale(
    id: sale.id,
    shopId: sale.shopId,
    productName: sale.productName,
    amount: sale.amount,
    date: sale.date,
    paymentMethod: sale.paymentMethod,
    isPaid: !sale.isPaid,
  );
  final shopService = ShopService();
  await shopService.updateSale(updatedSale);
}

void _confirmDeleteSale(BuildContext context, Sale sale) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Sale'),
      content: Text(
        'Are you sure you want to delete the sale for "${sale.productName}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final _shopService = ShopService();
            await _shopService.deleteSale(sale.id);
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

Widget _buildAmountInfoItem(
  String label,
  String value,
  IconData icon,
  Color color,
) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusButton(
  String label,
  IconData icon,
  bool isSelected,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(colors: [color, color.withOpacity(0.8)])
            : null,
        color: isSelected ? null : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.3),
          width: isSelected ? 0 : 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.white : color, size: 28),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMethodButton(
  String label,
  IconData icon,
  bool isSelected,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)])
            : null,
        color: isSelected ? null : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.3),
          width: isSelected ? 0 : 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Color(0xFF2196F3),
            size: 28,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF2196F3),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

void _updateSale(
  Sale sale,
  String paymentStatus,
  String paymentMethod,
  String additionalPayment,
  BuildContext context,
) async {
  try {
    double additionalAmount = 0.0;

    // Parse additional payment amount if provided
    if (additionalPayment.isNotEmpty) {
      additionalAmount = double.tryParse(additionalPayment) ?? 0.0;

      // Validate amount
      double remainingAmount = sale.amount - (sale.paidAmount ?? 0);
      if (additionalAmount > remainingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Amount cannot exceed remaining balance'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Calculate new paid amount
    double newPaidAmount = (sale.paidAmount ?? 0) + additionalAmount;

    // Automatically set to paid if full amount is received
    String finalStatus = paymentStatus;
    if (newPaidAmount >= sale.amount) {
      finalStatus = 'paid';
      newPaidAmount = sale.amount; // Cap at total price
    }
    ShopService _shopService = ShopService();
    // Update sale in database
    await _shopService.updateSale(
      Sale(
        id: sale.id,
        shopId: sale.shopId,
        productName: sale.productName,
        amount: newPaidAmount,
        date: sale.date,
        paymentMethod: paymentMethod,
      ),
    );

    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Sale updated successfully!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update sale: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

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
