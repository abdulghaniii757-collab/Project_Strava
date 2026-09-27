import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data sesuai tampilan UI
  final UserProfile user = UserProfile(
    name: 'Clara Nata Valentina',
    location: 'Daerah Khusus Ibukota Jakarta, Indonesia',
    avatarUrl: 'https://via.placeholder.com/150', // Bisa diganti URL foto profil/asset
    following: 5,
    followers: 0,
    totalActivities4Weeks: 0,
    recentDistance: 0.0,
    recentTime: '0h 0m',
    recentElevation: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.directions_run, color: Colors.deepOrange, size: 28),
            const SizedBox(width: 8),
            const Text(
              'STRAVA',
              style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {},
            ),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Profile & Activity Summary
                _buildProfileHeader(),
                const SizedBox(height: 32),

                // 2. Main Content & Sidebar Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 768;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Main Content
                        Expanded(
                          flex: isWide ? 7 : 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeatmapBanner(),
                              const SizedBox(height: 24),
                              _buildTabBar(),
                              const SizedBox(height: 16),
                              _buildRecentActivitiesSection(),
                            ],
                          ),
                        ),
                        if (isWide) const SizedBox(width: 32),
                        // Right Sidebar Content
                        if (isWide)
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildClubsSection(),
                                const Divider(height: 32),
                                _buildSocialStatsSection(),
                                const Divider(height: 32),
                                _buildMyStatsSection(),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    user.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Activity Tracker Box (Last 4 Weeks)
        Column(
          children: [
            const Text('Last 4 Weeks', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              '${user.totalActivities4Weeks}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Text('Total Activities', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatmapBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Heatmaps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create and share an interactive visualization of all the places you\'ve ever run or ridden.',
                  style: TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Create Your Heatmap', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          const Icon(Icons.map_outlined, size: 64, color: Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.deepOrange,
      unselectedLabelColor: Colors.black87,
      indicatorColor: Colors.deepOrange,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Trophy Case'),
        Tab(text: 'Following'),
        Tab(text: 'QOMs / CRs / Top 10s'),
        Tab(text: 'Local Legends'),
        Tab(text: 'Posts'),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activities for Sep 21, 2026 - Sep 27, 2026',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${user.recentDistance} km', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Text(user.recentTime, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Text('${user.recentElevation} m', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildClubsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Clubs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSocialStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Social Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Following', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${user.following}', style: const TextStyle(fontSize: 20, color: Colors.blue)),
              ],
            ),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Followers', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${user.followers}', style: const TextStyle(fontSize: 20, color: Colors.blue)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildStatRow('Activities / Week', '0'),
              _buildStatRow('Avg Time / Week', '0h 0m'),
              _buildStatRow('Avg Distance / Week', '0 km'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}