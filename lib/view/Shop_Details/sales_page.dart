import 'dart:io';

import 'package:daily_sales/controller/shop_services.dart';
import 'package:daily_sales/model/sale_models.dart';
import 'package:daily_sales/model/shop_models.dart';
import 'package:daily_sales/widget/bill_image_dialog.dart.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  final Shop shop;

  const SalesPage({super.key, required this.shop});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
    with SingleTickerProviderStateMixin {
  final BranchService _shopService = BranchService();
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
    return StreamBuilder<List<Branch_Sale>>(
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
    return StreamBuilder<List<Branch_Sale>>(
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
        }
        // else {
        //   sales = sales.where((sale) {
        //     return sale.date.year == _selectedDate.year &&
        //         sale.date.month == _selectedDate.month &&
        //         sale.date.day == _selectedDate.day;
        //   }).toList();
        // }

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

  Widget _buildSaleCard(Branch_Sale sale, int index) {
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
                      SizedBox(height: 12),

                      Row(
                        children: [
                          // VIEW BILL BUTTON
                          InkWell(
                            onTap: () {
                              showBillImagesDialog(context, sale.id);
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'View Bill',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          // DELETE BUTTON
                          InkWell(
                            onTap: () => _confirmDeleteSale(
                              context,
                              sale.productName,
                              sale.id,
                            ),
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
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
Widget _buildSaleCard(BuildContext context, Branch_Sale sale) {
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
void _showAddSaleDialog(BuildContext context, String shopId) {
  final productController = TextEditingController();
  final amountController = TextEditingController();
  List<XFile> billImages = []; // ← Must stay here
  final ImagePicker _picker = ImagePicker();
  DateTime selectedDate = DateTime.now();
  String paymentMethod = 'cash';
  bool isPaid = true;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                    // Product Name
                    TextFormField(
                      controller: productController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: const Icon(
                          Icons.shopping_bag,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    // Amount
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(value!) == null)
                          return 'Enter valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date
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
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
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
                    // Payment Method
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
                              Radio<String>(
                                value: 'cash',
                                groupValue: paymentMethod,
                                onChanged: (value) {
                                  setDialogState(() {
                                    paymentMethod = value!;
                                  });
                                },
                              ),
                              const Text('Cash'),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'bank',
                                groupValue: paymentMethod,
                                onChanged: (value) {
                                  setDialogState(() {
                                    paymentMethod = value!;
                                  });
                                },
                              ),
                              const Text('Bank'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Payment Status
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
                    const SizedBox(height: 16),
                    // Add Bill Image Button
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            //  await BranchService().addBillImage(saleId, downloadUrl);
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 70,
                            );
                            if (image != null) {
                              setDialogState(() {
                                billImages.add(image);
                              });
                            }
                          },
                          icon: Icon(Icons.add_a_photo),
                          label: const Text('Add Bill Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Image Preview
                    if (billImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: billImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(billImages[index].path),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        billImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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
                    final _shopService = BranchService();

                    // Upload images to Firebase Storage
                    List<String> uploadedUrls = [];
                    for (var image in billImages) {
                      final fileName =
                          '${DateTime.now().millisecondsSinceEpoch}.jpg';
                      final ref = FirebaseStorage.instance.ref().child(
                        'sales_bills/$fileName',
                      );
                      try {
                        // Upload file
                        await ref.putFile(File(image.path));

                        // Get the download URL
                        final url = await ref.getDownloadURL();
                        uploadedUrls.add(url);
                      } catch (e) {
                        print('Error uploading image: $e');
                      }
                    }

                    final sale = Branch_Sale(
                      id: '',
                      shopId: shopId,
                      productName: productController.text,
                      amount: double.parse(amountController.text),
                      date: selectedDate,
                      paymentMethod: paymentMethod,
                      isPaid: isPaid,
                      billImages: uploadedUrls, // new field
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
          );
        },
      );
    },
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
                final updatedSales = Branch_Sale(
                  id: id,
                  shopId: shopId,
                  productName: productController.text,
                  amount: double.parse(amountController.text),
                  date: selectedDate,
                  paymentMethod: paymentMethod,
                  isPaid: isPaid,
                );
                final shopService = BranchService();
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

void _togglePaymentStatus(Branch_Sale sale) async {
  final updatedSale = Branch_Sale(
    id: sale.id,
    shopId: sale.shopId,
    productName: sale.productName,
    amount: sale.amount,
    date: sale.date,
    paymentMethod: sale.paymentMethod,
    isPaid: !sale.isPaid,
  );
  final shopService = BranchService();
  await shopService.updateSale(updatedSale);
}

void _confirmDeleteSale(BuildContext context, productName, id) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Sale'),
      content: Text(
        'Are you sure you want to delete the sale for "${productName}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final _shopService = BranchService();
            await _shopService.deleteSale(id);
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
}Widget _buildAmountInfoItem(
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
  Branch_Sale sale,
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
    BranchService _shopService = BranchService();
    // Update sale in database
    await _shopService.updateSale(
      Branch_Sale(
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