import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/gear.dart';
import '../models/user_profile.dart';

/// Semua baca/tulis data permanen (shared_preferences) dikumpulin di sini,
/// biar halaman lain tinggal panggil, ga perlu tau soal shared_preferences.
class LocalStorage {
  static const _kActivities = 'activities';
  static const _kProfile = 'profile';
  static const _kGoal = 'weekly_goal_km';
  static const _kGear = 'gear_list';

  static Future<void> saveActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = activities.map((a) => a.toJson()).toList();
    await prefs.setString(_kActivities, jsonEncode(jsonList));
  }

  static Future<List<Activity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kActivities);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveGoal(double km) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kGoal, km);
  }

  static Future<double?> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kGoal);
  }

  static Future<void> saveGear(List<Gear> gearList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = gearList.map((g) => g.toJson()).toList();
    await prefs.setString(_kGear, jsonEncode(jsonList));
  }

  static Future<List<Gear>> loadGear() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kGear);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => Gear.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Hapus semua data yang kesimpen (aktivitas, profil, target, gear).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActivities);
    await prefs.remove(_kProfile);
    await prefs.remove(_kGoal);
    await prefs.remove(_kGear);
  }
}
