import 'package:daily_sales/view/sales_homePage.dart';
import 'package:daily_sales/view/shop_page.dart';
import 'package:flutter/material.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SalesHomePage(),
    const shops_page(),
    const AnalyticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        // appBar: AppBar(
        //   title: Text(_getAppBarTitle(_currentIndex)),
        //   actions: [if (_currentIndex == 0) _buildAppBarActions()],
        // ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Shops';
      case 2:
        return 'Analytics';
      case 3:
        return 'Settings';
      default:
        return 'Sales Management';
    }
  }

  Widget _buildAppBarActions() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
      ],
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s your sales summary for today',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Summary Cards
          Text(
            'Today\'s Summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildSummaryCard(
                'Total Revenue',
                'AED2,450',
                Colors.blue,
                Icons.attach_money,
              ),
              _buildSummaryCard(
                'Orders',
                '45',
                Colors.green,
                Icons.shopping_cart,
              ),
              _buildSummaryCard('Customers', '32', Colors.orange, Icons.people),
              _buildSummaryCard(
                'Conversion',
                '12.5%',
                Colors.purple,
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Sales
          Text(
            'Recent Sales',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text('Product Name'),
                  subtitle: Text('Customer Name'),
                  trailing: Text('AED 45.99'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              // style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Shop Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New Shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),

            // Shops List
            Text(
              'Your Shops',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Shop Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Colors.blue),
                    title: Text('Shop ${index + 1}'),
                    subtitle: const Text('Location, Phone'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Time Period Selector
          Row(
            children: [
              _buildTimeChip('Day', true),
              _buildTimeChip('Week', false),
              _buildTimeChip('Month', false),
              _buildTimeChip('Year', false),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Sales Trend',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Chart Visualization',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top Products
          Text(
            'Top Products',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      // child: Text('${index + 1}'),
                    ),
                    title: Text('Product Name'),
                    subtitle: Text('45 units sold'),
                    trailing: Text('AED 450'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),

          // Account Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile Information'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notification Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.palette),
                    title: Text('Theme'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Language'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.backup),
                    title: Text('Backup & Restore'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Support
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Help Center'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.contact_support),
                    title: Text('Contact Support'),
                  ),
                  const Divider(),
                  const ListTile(
                    // leading: Icon.info,
                    title: Text('About'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
