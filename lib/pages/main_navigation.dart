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

  static const _titles = ['Beranda', 'Statistik', 'Profil'];

  final _pages = const [
    HomePage(),
    StatsPage(),
    ProfilePage(),
  ];

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'stats_page.dart';
import 'profile_page.dart'; // Import profile_page

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StatsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
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

    // Dibikin ulang tiap build (bukan late final) biar halaman ikut
    // nampilin data terbaru setelah aktivitas ditambah atau pindah tab.
    final pages = [
      HomePage(onAddActivity: _openAddActivity),
      MapPage(onAddActivity: _openAddActivity),
      const StatsPage(),
      ProfilePage(refreshTick: _tick),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
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
