import 'package:flutter/material.dart';

import 'models/activity.dart';
import 'models/user_profile.dart';
import 'pages/login_page.dart';
import 'pages/main_navigation.dart';
import 'pages/profile_page.dart'; // Import halaman profile
import 'services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat data yang udah kesimpen sebelumnya (kalau ada) sebelum app dibuka.
  final savedActivities = await LocalStorage.loadActivities();
  dummyActivities.addAll(savedActivities);

  final savedProfile = await LocalStorage.loadProfile();
  if (savedProfile != null) {
    currentUser.name = savedProfile.name;
    currentUser.bio = savedProfile.bio;
    currentUser.location = savedProfile.location;
    currentUser.followers = savedProfile.followers;
    currentUser.following = savedProfile.following;
  }

  runApp(const StravaApp());
}

class StravaApp extends StatelessWidget {
  const StravaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strava Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/main': (context) => const MainNavigation(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}