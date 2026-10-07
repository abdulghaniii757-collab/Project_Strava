// Model untuk Tantangan / Challenge
class Challenge {
  final String id;
  final String title;
  final String description;
  final String period; // contoh: "1 Okt - 31 Okt 2026"
  final String type; // 'Strava Challenge' atau 'Group Challenge'
  final String goalType; // 'Group Goal', 'Most Activity', 'Fastest Effort'
  final double targetKm;
  final double progressKm;
  bool isJoined;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.type,
    required this.goalType,
    required this.targetKm,
    this.progressKm = 0.0,
    this.isJoined = false,
  });
}

// Model untuk Klub / Komunitas
class Club {
  final String id;
  final String name;
  final String description;
  final String location;
  final int memberCount;
  final String category; // 'Berlari', 'Bersepeda', dll.
  final bool isPrivate;
  bool isJoined;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.memberCount,
    required this.category,
    this.isPrivate = false,
    this.isJoined = false,
  });
}

// Model untuk Acara / Event
class Event {
  final String id;
  final String title;
  final String clubName;
  final String date; // contoh: "Minggu, 18 Okt 2026"
  final String time; // contoh: "07.00 WIB"
  final String location; // contoh: "GBK, Jakarta"
  final String distance; // contoh: "5 KM"
  final String pace; // contoh: "Pace 8-9"
  int participantCount;
  bool isJoined;

  Event({
    required this.id,
    required this.title,
    required this.clubName,
    required this.date,
    required this.time,
    required this.location,
    required this.distance,
    required this.pace,
    required this.participantCount,
    this.isJoined = false,
  });
}
