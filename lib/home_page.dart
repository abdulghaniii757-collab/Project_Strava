import 'package:flutter/material.dart';

import '../models/activity.dart';
import 'activity_detail_page.dart';
import 'add_activity_page.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onChanged;

  const HomePage({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas Saya'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dummyActivities.length,
        itemBuilder: (context, index) {
          final activity = dummyActivities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.deepOrange.shade100,
                child: Icon(activity.icon, color: Colors.deepOrange),
              ),
              title: Text(
                activity.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${activity.type} • ${activity.distanceKm} km • ${activity.duration}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ActivityDetailPage(activity: activity),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddActivityPage()),
          );
          onChanged(); // refresh setelah kembali dari form tambah
        },
      ),
    );
  }
}
