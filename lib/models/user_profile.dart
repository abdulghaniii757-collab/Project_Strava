class UserProfile {
  UserProfile({
    required this.name,
    this.bio = '',
    this.location = '',
    this.followers = 0,
    this.following = 0,
    this.avatarBase64 = '',
  });

  String name;
  String bio;
  String location;
  int followers;
  int following;

  /// Foto profil, disimpan sebagai teks base64 biar nyatu sama data
  /// profil lain di shared_preferences (ga perlu sistem file terpisah).
  String avatarBase64;

  Map<String, dynamic> toJson() => {
    'name': name,
    'bio': bio,
    'location': location,
    'followers': followers,
    'following': following,
    'avatarBase64': avatarBase64,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Pengguna',
    bio: json['bio'] as String? ?? '',
    location: json['location'] as String? ?? '',
    followers: json['followers'] as int? ?? 0,
    following: json['following'] as int? ?? 0,
    avatarBase64: json['avatarBase64'] as String? ?? '',
  );
}

/// Data profil user yang sedang login (sementara masih disimpan di memori).
final UserProfile currentUser = UserProfile(name: 'Pengguna');

/// Nama atlet yang diikuti user. Dipakai bareng sama Home, halaman
/// "Siapa yang Harus Diikuti", dan Profil (angka "Mengikuti").
final Set<String> followedAthletes = {};
