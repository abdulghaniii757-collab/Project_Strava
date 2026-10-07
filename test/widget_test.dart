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