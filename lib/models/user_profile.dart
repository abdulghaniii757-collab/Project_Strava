class UserProfile {
  UserProfile({
    required this.name,
    this.bio = '',
    this.location = '',
    this.followers = 0,
    this.following = 0,
  });

  String name;
  String bio;
  String location;
  int followers;
  int following;

  Map<String, dynamic> toJson() => {
    'name': name,
    'bio': bio,
    'location': location,
    'followers': followers,
    'following': following,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Pengguna',
    bio: json['bio'] as String? ?? '',
    location: json['location'] as String? ?? '',
    followers: json['followers'] as int? ?? 0,
    following: json['following'] as int? ?? 0,
  );
}

/// Data profil user yang sedang login (sementara masih disimpan di memori).
final UserProfile currentUser = UserProfile(name: 'Pengguna');
