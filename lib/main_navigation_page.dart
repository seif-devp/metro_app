import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_dashboard_page.dart';
import 'my_rides_page.dart';
import 'home_page.dart'; // Serving as New Ride page
import 'settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeDashboardPage(onNavigateTab: _onTabTapped),
          MyRidesPage(onNavigateTab: _onTabTapped),
          const HomePage(), // New Ride tab form
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          indicatorColor: const Color(0xFF4F46E5).withOpacity(0.18),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF4F46E5)),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.directions_subway_outlined),
              selectedIcon: const Icon(Icons.directions_subway_rounded, color: Color(0xFF4F46E5)),
              label: 'nav_my_rides'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_location_alt_outlined),
              selectedIcon: const Icon(Icons.add_location_alt_rounded, color: Color(0xFF4F46E5)),
              label: 'nav_new_ride'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded, color: Color(0xFF4F46E5)),
              label: 'nav_settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
