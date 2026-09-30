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
}

/// Data profil user yang sedang login (sementara masih disimpan di memori).
final UserProfile currentUser = UserProfile(name: 'Pengguna');