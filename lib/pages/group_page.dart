import 'package:flutter/material.dart';

import '../models/group.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data Dummy Grup/Klub
  List<Group> dummyGroups = [
    Group(
      id: '1',
      name: 'Runners Jakarta',
      description: 'Komunitas lari santai daerah Jakarta dan sekitarnya.',
      memberCount: 1250,
      category: 'Berlari',
      isJoined: false,
    ),
    Group(
      id: '2',
      name: 'Cyclist Nusantara',
      description: 'Grup gowes bareng akhir pekan.',
      memberCount: 840,
      category: 'Bersepeda',
      isJoined: true,
    ),
    Group(
      id: '3',
      name: 'Pluit Swim Club',
      description: 'Klub renang rutin setiap Sabtu pagi.',
      memberCount: 310,
      category: 'Berenang',
      isJoined: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleJoin(Group group) {
    setState(() {
      group.isJoined = !group.isJoined;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          group.isJoined
              ? 'Berhasil bergabung dengan ${group.name}'
              : 'Keluar dari ${group.name}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Tema Gelap ala Strava
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Grup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepOrange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Tantangan'),
            Tab(text: 'Klub'),
            Tab(text: 'Acara'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Tantangan
          const Center(
            child: Text(
              'Tantangan Lari & Bersepeda',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Tab 2: Daftar Klub / Grup
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dummyGroups.length,
            itemBuilder: (context, index) {
              final group = dummyGroups[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.category} • ${group.memberCount} Anggota',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        group.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: group.isJoined
                                ? Colors.grey[800]
                                : Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _toggleJoin(group),
                          child: Text(
                            group.isJoined ? 'Tergabung' : 'Bergabung',
                            style: TextStyle(
                              color: group.isJoined
                                  ? Colors.white70
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab 3: Acara
          const Center(
            child: Text(
              'Jadwal Acara Komunitas',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
