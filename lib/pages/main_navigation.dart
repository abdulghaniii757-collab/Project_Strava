import 'package:flutter/material.dart';

import '../services/challenge_service.dart';

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
    _onActivityChanged();
  }

  void _onActivityChanged() {
    if (!mounted) return;
    setState(() => _tick++);
    ChallengeService.checkCompletion(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMap = _currentIndex == 1;

    final pages = [
      HomePage(onAddActivity: _openAddActivity),
      MapPage(onActivityRecorded: _onActivityChanged),
      StatsPage(isActive: _currentIndex == 2, refreshTick: _tick),
      const GroupPage(),
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
            icon: Icon(Icons.route_outlined),
            label: 'Rute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Grup',
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
