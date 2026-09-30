import 'package:flutter/material.dart';

import 'home_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'add_activity_page.dart';
import 'map_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _tick =
      0; // dinaikin tiap ada aktivitas baru biar semua halaman ikut refresh

  late final _pages = [
    HomePage(onAddActivity: _openAddActivity),
    MapPage(onAddActivity: _openAddActivity),
    StatsPage(),
    ProfilePage(),
  ];

  Future<void> _openAddActivity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityPage()),
    );
    if (mounted) setState(() => _tick++);
  }

  @override
  Widget build(BuildContext context) {
    final isMap = _currentIndex == 1;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: isMap
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: _openAddActivity,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked),
            label: 'Rekam',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Anda',
          ),
        ],
      ),
    );
  }
}
