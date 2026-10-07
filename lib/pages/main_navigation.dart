import 'package:flutter/material.dart';

<<<<<<< HEAD
=======
import '../services/challenge_service.dart';

>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
import 'home_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'add_activity_page.dart';
import 'group_page.dart';
import 'map_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _tick = 0;

  Future<void> _openAddActivity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityPage()),
    );
<<<<<<< HEAD
    if (mounted) setState(() => _tick++);
=======
    _onActivityChanged();
  }

  void _onActivityChanged() {
    if (!mounted) return;
    setState(() => _tick++);
    ChallengeService.checkCompletion(context);
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
  }

  @override
  Widget build(BuildContext context) {
    final isMap = _currentIndex == 1;

<<<<<<< HEAD
    // Dibikin ulang tiap build (bukan late final) biar halaman ikut
    // nampilin data terbaru setelah aktivitas ditambah atau pindah tab.
    final pages = [
      HomePage(onAddActivity: _openAddActivity),
      MapPage(onAddActivity: _openAddActivity),
      const StatsPage(),
=======
    final pages = [
      HomePage(onAddActivity: _openAddActivity),
      MapPage(onActivityRecorded: _onActivityChanged),
      StatsPage(isActive: _currentIndex == 2, refreshTick: _tick),
      const GroupPage(),
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
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
<<<<<<< HEAD
            icon: Icon(Icons.radio_button_checked),
            label: 'Rekam',
=======
            icon: Icon(Icons.route_outlined),
            label: 'Rute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Grup',
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
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
