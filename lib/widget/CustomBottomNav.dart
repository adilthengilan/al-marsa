import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:daily_sales/view/branch_management.dart';
import 'package:daily_sales/view/Dashboard/dashboard_page.dart';
import 'package:daily_sales/view/settings_page.dart';
import 'package:daily_sales/view/Shop_Details/shop_page.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, this.selectedIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int selectedIndex;

  final List<Widget> screens = [
    DashboardPage(),
    shops_page(),
    Branch_Page(),
    SettingsPage(),
  ];

  final List<IconData> icons = [
    Icons.dashboard_outlined,
    Icons.storefront_outlined,
    Icons.analytics_outlined,
    Icons.settings_outlined,
  ];

  final List<IconData> activeIcons = [
    Icons.dashboard,
    Icons.storefront,
    Icons.analytics,
    Icons.settings,
  ];

  final List<String> labels = ['Dashboard', 'Shops', 'Analytics', 'Settings'];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            color: Colors.blue.shade50,
            buttonBackgroundColor: Colors.blue.shade100,
            index: selectedIndex,
            height: 65,
            animationDuration: const Duration(milliseconds: 300),
            items: List.generate(icons.length, (index) {
              final isSelected = selectedIndex == index;
              return Icon(
                isSelected ? activeIcons[index] : icons[index],
                size: isSelected ? 32 : 26,
                color: Colors.blue,
              );
            }),
            onTap: (index) {
              setState(() => selectedIndex = index);
            },
          ),

          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (index) {
                final isSelected = selectedIndex == index;
                return Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.blue.shade700
                        : Colors.blue.shade300,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
