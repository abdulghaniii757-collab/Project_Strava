import 'package:flutter/material.dart';

import '../models/group.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Data Dummy Tantangan / Challenges
  List<Challenge> challenges = [
    Challenge(
      id: 'c1',
      title: 'Sunday Girls 500 KM Together',
      description:
          'Semua anggota komunitas bekerja sama mencapai target total 500 KM.',
      period: '10 Okt - 20 Okt 2026',
      type: 'Group Challenge',
      goalType: 'Group Goal',
      targetKm: 500.0,
      progressKm: 320.5,
      isJoined: true,
    ),
    Challenge(
      id: 'c2',
      title: 'Tantangan Berkeringat 180 Menit',
      description: 'Selesaikan aktivitas berdurasi total 180 menit selama bulan Oktober.',
      period: '1 Okt - 31 Okt 2026',
      type: 'Strava Challenge',
      goalType: 'Most Activity',
      targetKm: 180.0,
      progressKm: 45.0,
      isJoined: false,
    ),
  ];

  // 2. Data Dummy Klub / Clubs
  List<Club> clubs = [
    Club(
      id: 'k1',
      name: 'Sunday Girls Jakarta',
      description: 'Women-only running & wellness community di Jakarta.',
      location: 'Jakarta, Indonesia',
      memberCount: 245,
      category: 'Berlari',
      isPrivate: true,
      isJoined: true,
    ),
    Club(
      id: 'k2',
      name: 'Cyclist Nusantara',
      description: 'Grup gowes bareng keliling kota setiap akhir pekan.',
      location: 'Jakarta & Tangerang',
      memberCount: 840,
      category: 'Bersepeda',
      isPrivate: false,
      isJoined: false,
    ),
  ];

  // 3. Data Dummy Acara / Events
  List<Event> events = [
    Event(
      id: 'e1',
      title: 'Sunday Morning Run GBK',
      clubName: 'Sunday Girls Jakarta',
      date: 'Minggu, 18 Okt 2026',
      time: '07:00 WIB',
      location: 'Plaza Utara GBK, Jakarta',
      distance: '5 KM',
      pace: 'Pace 8-9',
      participantCount: 28,
      isJoined: true,
    ),
    Event(
      id: 'e2',
      title: 'Gowes Santai Loop Monas',
      clubName: 'Cyclist Nusantara',
      date: 'Sabtu, 24 Okt 2026',
      time: '06:00 WIB',
      location: 'Monas Barat Daya, Jakarta',
      distance: '15 KM',
      pace: 'Speed 20 km/j',
      participantCount: 42,
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

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        children: [_buildChallengeTab(), _buildClubTab(), _buildEventTab()],
      ),
    );
  }

  // --- TAB 1: TANTANGAN (CHALLENGES) ---
  Widget _buildChallengeTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final item = challenges[index];
        final double progressPercent = (item.progressKm / item.targetKm).clamp(
          0.0,
          1.0,
        );

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.type,
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      item.period,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),

                // Progress Bar
                if (item.isJoined) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progres: ${item.progressKm.toInt()} / ${item.targetKm.toInt()} KM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(progressPercent * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.grey[800],
                    color: Colors.deepOrange,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 14),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.isJoined
                          ? Colors.grey[800]
                          : Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        item.isJoined = !item.isJoined;
                      });
                      _showToast(
                        item.isJoined
                            ? 'Berhasil bergabung dengan tantangan!'
                            : 'Batal mengikuti tantangan.',
                      );
                    },
                    child: Text(
                      item.isJoined ? 'Tergabung' : 'Ikuti Tantangan',
                      style: TextStyle(
                        color: item.isJoined ? Colors.white70 : Colors.white,
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
    );
  }

  // --- TAB 2: KLUB (CLUBS) ---
  Widget _buildClubTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepOrange,
                      child: Text(
                        club.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  club.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (club.isPrivate)
                                const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                            ],
                          ),
                          Text(
                            '${club.category} • ${club.location}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  club.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  '${club.memberCount} Anggota',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: club.isJoined
                          ? Colors.grey[800]
                          : Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        club.isJoined = !club.isJoined;
                        if (club.isJoined) club.memberCount;
                      });
                      _showToast(
                        club.isJoined
                            ? 'Berhasil bergabung ke ${club.name}'
                            : 'Keluar dari ${club.name}',
                      );
                    },
                    child: Text(
                      club.isJoined
                          ? 'Tergabung'
                          : (club.isPrivate ? 'Minta Bergabung' : 'Bergabung'),
                      style: TextStyle(
                        color: club.isJoined ? Colors.white70 : Colors.white,
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
    );
  }

  // --- TAB 3: ACARA (EVENTS) ---
  Widget _buildEventTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.clubName,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.participantCount} Orang Ikut',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${event.date} • ${event.time}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_run,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${event.distance} (${event.pace})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.isJoined
                          ? Colors.grey[800]
                          : Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        event.isJoined = !event.isJoined;
                        if (event.isJoined) {
                          event.participantCount += 1;
                        } else {
                          event.participantCount -= 1;
                        }
                      });
                      _showToast(
                        event.isJoined
                            ? 'Kamu terdaftar pada acara ini!'
                            : 'Batal mengikuti acara.',
                      );
                    },
                    child: Text(
                      event.isJoined ? 'Saya Ikut (RSVP)' : 'Ikut Acara',
                      style: TextStyle(
                        color: event.isJoined ? Colors.white70 : Colors.white,
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
    );
  }
}
