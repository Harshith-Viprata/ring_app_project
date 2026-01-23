import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../device/presentation/pages/device_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
// import '../../profile/presentation/pages/profile_page.dart'; // To be created

class MainScaffoldPage extends StatefulWidget {
  const MainScaffoldPage({super.key});

  @override
  State<MainScaffoldPage> createState() => _MainScaffoldPageState();
}

class _MainScaffoldPageState extends State<MainScaffoldPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const DevicePage(), 
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.watch_outlined),
            selectedIcon: Icon(Icons.watch),
            label: 'Device',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
