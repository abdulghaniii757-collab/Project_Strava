class Group {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String category; // Misal: 'Berlari', 'Bersepeda', dll.
  bool isJoined;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.category,
    this.isJoined = false,
  });
}
