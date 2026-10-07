import 'package:flutter/material.dart';

import '../models/challenge.dart';
import '../pages/notifications_page.dart';
import 'local_storage.dart';

class ChallengeService {
  static Future<void> load() async {
    final saved = await LocalStorage.loadChallenges();
    joinedChallengeMonths.addAll(saved.joined);
    completedChallengeMonths.addAll(saved.completed);
  }

  static Future<void> _save() => LocalStorage.saveChallenges(
    joined: joinedChallengeMonths,
    completed: completedChallengeMonths,
  );

  static bool get joinedThisMonth =>
      joinedChallengeMonths.contains(challengeMonthKey(DateTime.now()));

  static Future<void> setJoined(bool joined) async {
    final key = challengeMonthKey(DateTime.now());
    if (joined) {
      joinedChallengeMonths.add(key);
    } else {
      joinedChallengeMonths.remove(key);
    }
    await _save();
  }

  static Future<void> checkCompletion(BuildContext context) async {
    final key = challengeMonthKey(DateTime.now());
    if (!joinedChallengeMonths.contains(key) ||
        completedChallengeMonths.contains(key) ||
        challengeKmFor(key) < challengeTargetKm) {
      return;
    }

    completedChallengeMonths.add(key);
    await _save();

    final bulan = challengeMonthLabel(key);
    addNotification(
      NotificationItem(
        name: 'Trekora',
        aksi: 'Selamat! Kamu menyelesaikan Tantangan 50 KM $bulan dan '
            'mendapat lencana baru',
        waktu: 'Baru saja',
        icon: Icons.emoji_events,
      ),
    );

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 56),
        title: const Text(
          'Tantangan Selesai!',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Kamu udah ngumpulin ${challengeTargetKm.toStringAsFixed(0)} km '
          'bulan ini. Lencana "Tantangan 50 KM $bulan" sekarang ada di '
          'profilmu.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantap', style: TextStyle(color: Colors.deepOrange)),
          ),
        ],
      ),
    );
  }
}
