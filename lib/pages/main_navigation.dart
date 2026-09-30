import 'package:flutter/material.dart';

import 'home_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'add_activity_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _tick =
      0; // dinaikin tiap ada aktivitas baru biar semua halaman ikut refresh

  static const _titles = ['Beranda', 'Statistik', 'Profil'];

  late final _pages = [
    HomePage(onAddActivity: _openAddActivity),
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
    final isHome = _currentIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: isHome
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: _openAddActivity,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
