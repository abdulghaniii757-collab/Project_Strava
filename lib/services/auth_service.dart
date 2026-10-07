import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Satu akun yang terdaftar di perangkat ini.
class Account {
  const Account({
    required this.name,
    required this.email,
    required this.salt,
    required this.passwordHash,
  });

  final String name;

  /// Disimpan huruf kecil semua, biar email tidak peka huruf besar-kecil.
  final String email;
  final String salt;
  final String passwordHash;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'salt': salt,
    'passwordHash': passwordHash,
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    name: json['name'] as String,
    email: json['email'] as String,
    salt: json['salt'] as String,
    passwordHash: json['passwordHash'] as String,
  );
}

/// Daftar dan masuk, semuanya lokal di perangkat (belum ada server).
/// Kata sandi tidak disimpan apa adanya, tapi di-hash SHA-256 + salt.
class AuthService {
  static const storageKey = 'registered_accounts';
  static const minPasswordLength = 6;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  static String _newSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  static Future<List<Account>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Data rusak dianggap belum ada akun, biar app tidak macet di login.
      return [];
    }
  }

  static Future<void> _save(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  static Future<bool> hasAccounts() async => (await _load()).isNotEmpty;

  /// Mengembalikan pesan error kalau gagal, atau `null` kalau berhasil.
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String confirm,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty ||
        cleanEmail.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      return 'Mohon lengkapi semua kolom.';
    }
    if (!_emailPattern.hasMatch(cleanEmail)) {
      return 'Format email tidak valid.';
    }
    if (password.length < minPasswordLength) {
      return 'Kata sandi minimal $minPasswordLength karakter.';
    }
    if (password != confirm) {
      return 'Konfirmasi kata sandi tidak sama.';
    }

    final accounts = await _load();
    if (accounts.any((a) => a.email == cleanEmail)) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }

    final salt = _newSalt();
    accounts.add(
      Account(
        name: cleanName,
        email: cleanEmail,
        salt: salt,
        passwordHash: _hash(salt, password),
      ),
    );
    await _save(accounts);
    return null;
  }

  /// Mengembalikan akun kalau email dan kata sandi cocok, selain itu `null`.
  static Future<Account?> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final accounts = await _load();
    for (final account in accounts) {
      if (account.email == cleanEmail &&
          account.passwordHash == _hash(account.salt, password)) {
        return account;
      }
    }
    return null;
  }
}