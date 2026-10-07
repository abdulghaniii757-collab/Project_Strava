<<<<<<< HEAD
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:project_strava/main.dart';

void main() {
  testWidgets('app menampilkan halaman login', (WidgetTester tester) async {
    await tester.pumpWidget(const StravaApp());

    expect(find.text('strava'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
  });
}
=======
import 'package:flutter_test/flutter_test.dart';
import 'package:project_strava/main.dart';
import 'package:project_strava/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pertama kali dibuka, pengguna wajib daftar dulu', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TrekoraApp());
    await tester.pumpAndSettle();

    expect(find.text('Trekora'), findsOneWidget);
    expect(find.text('DAFTAR'), findsOneWidget);
    expect(find.text('MASUK'), findsNothing);
  });

  testWidgets('kalau sudah ada akun, tampil halaman masuk', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AuthService.register(
      name: 'Budi',
      email: 'budi@mail.com',
      password: 'rahasia1',
      confirm: 'rahasia1',
    );

    await tester.pumpWidget(const TrekoraApp());
    await tester.pumpAndSettle();

    expect(find.text('Trekora'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('DAFTAR'), findsNothing);
  });
}
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
