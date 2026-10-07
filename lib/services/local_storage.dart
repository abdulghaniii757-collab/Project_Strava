import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/gear.dart';
import '../models/saved_route.dart';
import '../models/user_profile.dart';

class LocalStorage {
  static const _kActivities = 'activities';
  static const _kProfile = 'profile';
  static const _kGoal = 'weekly_goal_km';
  static const _kGear = 'gear_list';
  static const _kFollowing = 'followed_athletes';
  static const _kRoutes = 'saved_routes';
  static const _kChallengeJoined = 'challenge_joined_months';
  static const _kChallengeDone = 'challenge_completed_months';

  static Future<void> saveRoutes(List<SavedRoute> routes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = routes.map((route) => route.toJson()).toList();
    await prefs.setString(_kRoutes, jsonEncode(jsonList));
  }

  static Future<List<SavedRoute>> loadRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRoutes);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((route) => SavedRoute.fromJson(route as Map<String, dynamic>))
        .toList();
  }

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

  static Future<void> saveFollowing(Set<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFollowing, names.toList());
  }

  static Future<Set<String>> loadFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kFollowing) ?? []).toSet();
  }

  static Future<void> saveChallenges({
    required Set<String> joined,
    required Set<String> completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kChallengeJoined, joined.toList());
    await prefs.setStringList(_kChallengeDone, completed.toList());
  }

  static Future<({Set<String> joined, Set<String> completed})>
      loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      joined: (prefs.getStringList(_kChallengeJoined) ?? []).toSet(),
      completed: (prefs.getStringList(_kChallengeDone) ?? []).toSet(),
    );
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActivities);
    await prefs.remove(_kProfile);
    await prefs.remove(_kGoal);
    await prefs.remove(_kGear);
    await prefs.remove(_kFollowing);
    await prefs.remove(_kRoutes);
    await prefs.remove(_kChallengeJoined);
    await prefs.remove(_kChallengeDone);
  }
}
