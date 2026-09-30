  import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/main_navigation.dart';
import 'pages/profile_page.dart'; // Import halaman profile

void main() {
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
      // Ganti sementara ke ProfilePage() agar langsung tampil saat di-run
      home: const LoginPage(),
      routes: {
        '/main': (context) => const MainNavigation(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  } 
}