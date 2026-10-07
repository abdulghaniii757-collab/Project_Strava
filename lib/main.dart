import 'package:flutter/material.dart';

import 'models/activity.dart';
<<<<<<< HEAD
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
    currentUser.avatarBase64 = savedProfile.avatarBase64;
  }

  runApp(const StravaApp());
=======
import 'models/post_comment.dart';
import 'models/user_profile.dart';
import 'pages/login_page.dart';
import 'pages/main_navigation.dart';
import 'pages/profile_page.dart'; 
import 'services/challenge_service.dart';
import 'services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedActivities = await LocalStorage.loadActivities();
  dummyActivities.addAll(savedActivities);

  final savedProfile = await LocalStorage.loadProfile();
  if (savedProfile != null) {
    currentUser.name = savedProfile.name;
    currentUser.bio = savedProfile.bio;
    currentUser.location = savedProfile.location;
    currentUser.followers = savedProfile.followers;
    currentUser.following = savedProfile.following;
    currentUser.avatarBase64 = savedProfile.avatarBase64;
  }

  followedAthletes.addAll(await LocalStorage.loadFollowing());
  await ChallengeService.load();
  postComments.addAll(await LocalStorage.loadComments());

  runApp(const TrekoraApp());
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
}

class TrekoraApp extends StatelessWidget {
  const TrekoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trekora',
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