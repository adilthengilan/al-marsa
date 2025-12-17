import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();
  int _selectedTimeRange = 0;
  //OVERVIEW GRID TILES DATA//
  double totalRevenue = 0;
  int totalOrders = 0;
  int totalCustomers = 0;
  double conversionRate = 0.0;
  double customerChange = 0.0;
  double conversionChange = 0.0;
  //SALES CHART DATA//
  List<Map<String, dynamic>> last7DaysData = [];

  // Fetch summary data from Firestore of overview//
  Future<void> fetchSummaryData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('branch_sales')
        .get();

    double revenue = 0;
    int orders = querySnapshot.docs.length;

    final Set<String> uniqueShops = {}; // we treat shopId as customer

    for (var doc in querySnapshot.docs) {
      revenue += (doc['amount'] ?? 0).toDouble();

      if (doc['shopId'] != null) {
        uniqueShops.add(doc['shopId']);
      }
    }

    int customers = uniqueShops.length;
    double conversion = customers > 0 ? (orders / customers) * 100 : 0;

    setState(() {
      totalRevenue = revenue;
      totalOrders = orders;
      totalCustomers = customers;
      conversionRate = conversion;
    });
  }

  // Fetch sales chart data from Firestore of sales chart//
  Future<void> fetchSalesChartData() async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 6)); // last 7 days

    final querySnapshot = await FirebaseFirestore.instance
        .collection('branch_sales')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date')
        .get();

    // Fill last 7 days with zero values first
    Map<String, double> dailyTotals = {};
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = "${date.year}-${date.month}-${date.day}";
      dailyTotals[key] = 0.0;
    }

    // Add Firestore revenue
    for (var doc in querySnapshot.docs) {
      final DateTime date = (doc['date'] as Timestamp).toDate();
      final key = "${date.year}-${date.month}-${date.day}";

      dailyTotals[key] =
          (dailyTotals[key] ?? 0) + (doc['amount'] ?? 0).toDouble();
    }

    // Convert to list for chart
    List<Map<String, dynamic>> formatted = [];
    dailyTotals.forEach((key, value) {
      formatted.add({'date': key, 'value': value});
    });

    setState(() {
      last7DaysData = formatted.reversed.toList(); // oldest → newest
    });
  }

  // Animation controllers
  late final AnimationController _headerController;
  late final AnimationController _cardController;
  late final AnimationController _chartController;
  late final AnimationController _productController;
  late final AnimationController _pulseController;

  // Animation values
  late final Animation<double> _headerAnimation;
  late final Animation<double> _cardAnimation;
  late final Animation<double> _chartAnimation;
  late final Animation<double> _productAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  // Sample data
  List<Map<String, dynamic>> get summaryCards => [
    {
      'title': 'Total Revenue',
      'value': 'AED ${totalRevenue.toStringAsFixed(2)}',
      'change': '+${((totalRevenue / 10000) * 10).toStringAsFixed(1)}%',
      'icon': Icons.attach_money_rounded,
      'gradient': [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
    {
      'title': 'Orders',
      'value': '$totalOrders',
      'change': '+${(totalOrders * 0.1).toStringAsFixed(1)}%',
      'icon': Icons.shopping_bag_rounded,
      'gradient': [Color(0xFF1E88E5), Color(0xFF1565C0)],
    },
    {
      'title': 'Customers',
      'value': '$totalCustomers',
      'change': '+${(totalCustomers * 0.05).toStringAsFixed(1)}%',
      'icon': Icons.people_rounded,
      'gradient': [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    },
    {
      'title': 'Conversion',
      'value': '${conversionRate.toStringAsFixed(1)}%',
      'change': '+${(conversionRate * 0.02).toStringAsFixed(1)}%',
      'icon': Icons.trending_up_rounded,
      'gradient': [Color(0xFF64B5F6), Color(0xFF42A5F5)],
    },
  ];

  final List<Map<String, dynamic>> topProducts = [
    {'name': 'Premium Headphones', 'sales': 45, 'value': 'AED 4,500'},
    {'name': 'Smart Watch', 'sales': 38, 'value': 'AED 3,800'},
    {'name': 'Wireless Earbuds', 'sales': 32, 'value': 'AED 3,200'},
    {'name': 'Laptop Stand', 'sales': 28, 'value': 'AED 2,800'},
    {'name': 'USB-C Cable', 'sales': 24, 'value': 'AED 1,200'},
  ];

  @override
  void initState() {
    super.initState();
    fetchSummaryData();
    fetchSalesChartData(); // <-- add this
    // Initialize controllers first
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _productController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize animations
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeInOut,
    );

    _productAnimation = CurvedAnimation(
      parent: _productController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _productController, curve: Curves.easeOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _productController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations with staggered delays
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), _cardController.forward);
    Future.delayed(const Duration(milliseconds: 400), _chartController.forward);
    Future.delayed(
      const Duration(milliseconds: 600),
      _productController.forward,
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _chartController.dispose();
    _productController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
      // bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDateSelector(),
          const SizedBox(height: 28),
          _buildSummaryCards(),
          const SizedBox(height: 28),
          _buildSalesChart(),
          const SizedBox(height: 28),
          _buildTopProducts(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _headerAnimation.value,
          child: Opacity(
            opacity: _headerAnimation.value.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Dashboard',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                              ).createShader(Rect.fromLTWH(0, 0, 300, 70)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your performance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardAnimation.value) * 20),
          child: Opacity(
            opacity: _cardAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.9)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
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
                            _selectedDate.toString().substring(0, 10),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ],
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
      },
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: summaryCards.length,
          itemBuilder: (context, index) {
            final card = summaryCards[index];
            return FadeTransition(
              opacity: _cardAnimation.drive(
                Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.linear)),
              ),

              child: ScaleTransition(
                scale: _cardAnimation,
                child: TweenAnimationBuilder(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: card['gradient'],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: card['gradient'][0].withOpacity(0.4),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Decorative circles
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              left: -10,
                              bottom: -10,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          card['icon'],
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: card['change'].startsWith('+')
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              card['change'].startsWith('+')
                                                  ? Icons.arrow_upward_rounded
                                                  : Icons
                                                        .arrow_downward_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              card['change'],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        card['title'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        card['value'],
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
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
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Trend',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _chartAnimation.drive(Tween<double>(begin: 0.0, end: 1.0)),

          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_chartAnimation),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withOpacity(0.95)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // LEFT SIDE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Performance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Last 7 days',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        // RIGHT SIDE (SCROLLABLE)
                        // SingleChildScrollView(
                        //   scrollDirection: Axis.horizontal,
                        //   child: Row(
                        //     children: [
                        //       _buildAnimatedTimeTab('Day', 0),
                        //       _buildAnimatedTimeTab('Week', 1),
                        //       _buildAnimatedTimeTab('Month', 2),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(height: 200, child: _buildAnimatedChart()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChart() {
    if (last7DaysData.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // max value for Y axis
    double maxY =
        last7DaysData.map((e) => e['value']).reduce((a, b) => a > b ? a : b) +
        1;

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: maxY,

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.blue.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),

            // ==== TITLES ====
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${(value).toStringAsFixed(0)}k',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,

                  getTitlesWidget: (value, meta) {
                    const days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),

            borderData: FlBorderData(show: false),

            // ========== LINE =============
            lineBarsData: [
              LineChartBarData(
                spots: last7DaysData.asMap().entries.map((entry) {
                  int index = entry.key;
                  double value = entry.value['value'] ?? 0;

                  return FlSpot(
                    index.toDouble(),
                    value * _chartAnimation.value,
                  );
                }).toList(),

                isCurved: true,
                barWidth: 4,

                // BLUE COLOR
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),

                // ROUND DOTS (OLD UI)
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: Color(0xFF2196F3),
                    );
                  },
                ),

                // GRADIENT BELOW LINE (OLD UI)
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2196F3).withOpacity(0.3),
                      Color(0xFF2196F3).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Products',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 16),
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _productAnimation.drive(
              Tween<double>(begin: 0.0, end: 1.0),
            ),

            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withOpacity(0.95)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset((1 - value) * 50, 0),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2196F3).withOpacity(0.1),
                                  Colors.white.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2196F3),
                                        Color(0xFF1976D2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${product['sales']} units sold',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      product['value'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up_rounded,
                                            color: Colors.green,
                                            size: 12,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            '+${(product['sales'] * 0.15).toInt()}%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTimeTab(String text, int index) {
    bool isActive = _selectedTimeRange == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)])
              : null,
          color: isActive ? null : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Color(0xFF2196F3),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
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
}
