import 'package:flutter/material.dart';
import '../models/activity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = dummyActivities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          
          return ListTile(
            leading: const Icon(Icons.directions_run),
            title: Text(activity.name),
            subtitle: Text('${activity.distanceKm} km'),
          );
        },
      ),
    );
  }
}