import 'package:flutter_test/flutter_test.dart';
import 'package:project_strava/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _daftar({
  String name = 'Budi',
  String email = 'budi@mail.com',
  String password = 'rahasia1',
  String? confirm,
}) {
  return AuthService.register(
    name: name,
    email: email,
    password: password,
    confirm: confirm ?? password,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('awalnya belum ada akun', () async {
    expect(await AuthService.hasAccounts(), isFalse);
  });

  test('daftar berhasil, lalu bisa masuk', () async {
    expect(await _daftar(), isNull);
    expect(await AuthService.hasAccounts(), isTrue);

    final account = await AuthService.login('budi@mail.com', 'rahasia1');
    expect(account, isNotNull);
    expect(account!.name, 'Budi');
  });

  test('email tidak peka huruf besar-kecil', () async {
    await _daftar(email: 'Budi@Mail.com');
    expect(await AuthService.login('budi@mail.COM', 'rahasia1'), isNotNull);
  });

  test('kata sandi salah ditolak', () async {
    await _daftar();
    expect(await AuthService.login('budi@mail.com', 'salah'), isNull);
  });

  test('email yang sama tidak bisa daftar dua kali', () async {
    await _daftar();
    expect(await _daftar(email: 'BUDI@mail.com'), isNotNull);
  });

  test('isian pendaftaran divalidasi', () async {
    expect(await _daftar(name: '  '), isNotNull);
    expect(await _daftar(email: 'bukan-email'), isNotNull);
    expect(await _daftar(password: '123'), isNotNull);
    expect(await _daftar(confirm: 'beda'), isNotNull);
    expect(await AuthService.hasAccounts(), isFalse);
  });

  test('kata sandi tidak disimpan sebagai teks biasa', () async {
    await _daftar();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthService.storageKey)!;
    expect(raw.contains('rahasia1'), isFalse);
  });
}