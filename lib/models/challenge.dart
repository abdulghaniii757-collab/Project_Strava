import 'activity.dart';

const double challengeTargetKm = 50;

final Set<String> joinedChallengeMonths = {};

final Set<String> completedChallengeMonths = {};

String challengeMonthKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

const _namaBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String challengeMonthLabel(String key) {
  final parts = key.split('-');
  return '${_namaBulan[int.parse(parts[1]) - 1]} ${parts[0]}';
}

bool countsForChallenge(Activity a) => a.type == 'Lari' || a.type == 'Jalan Kaki';

double challengeKmFor(String key) => dummyActivities
    .where((a) => countsForChallenge(a) && challengeMonthKey(a.date) == key)
    .fold<double>(0, (sum, a) => sum + a.distanceKm);

int challengeDaysLeft() {
  final now = DateTime.now();
  final lastDay = DateTime(now.year, now.month + 1, 0).day;
  return lastDay - now.day;
}
