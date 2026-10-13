import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simaul_mobile/core/utils/session_manager.dart';
import 'package:simaul_mobile/main.dart';
import 'package:simaul_mobile/models/user_model.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
  });

  testWidgets('Test 1: Sesi kosong -> Splash -> Landing Page', (WidgetTester tester) async {
    await tester.pumpWidget(const SimaulMobileApp());
    expect(find.text('SIMAUL'), findsOneWidget);

    // Fast-forward melewati durasi splash
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Menampilkan Landing Page
    expect(find.text('Layanan Perawatan & Servis Terpadu'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Jelajahi Katalog Layanan'), findsOneWidget);
  });

  testWidgets('Test 2: Dari Landing Page klik Masuk -> Tampil Login dengan form kosong', (WidgetTester tester) async {
    await tester.pumpWidget(const SimaulMobileApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke SIMAUL'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    // Form email awal harus kosong (tidak otomatis isi akun)
    expect(find.text('customer@example.com'), findsNothing);
  });

  testWidgets('Test 3: Cold start dalam keadaan login customer -> Langsung ke Dashboard Pelanggan', (WidgetTester tester) async {
    final customer = UserModel(
      id: 1,
      name: 'Rian Saputra',
      email: 'customer@example.com',
      role: 'customer',
      points: 150,
    );

    SharedPreferences.setMockInitialValues({
      'auth_token': 'fake_token_123',
      'auth_user': jsonEncode(customer.toJson()),
    });
    await SessionManager.init();

    await tester.pumpWidget(const SimaulMobileApp());
    expect(find.text('SIMAUL'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Langsung berada di Dashboard Pelanggan
    expect(find.text('Rian Saputra'), findsOneWidget);
    expect(find.text('Buat Booking'), findsOneWidget);
  });

  testWidgets('Test 4: Clear auth / logout -> Sesi terhapus dan kembali ke Landing Page', (WidgetTester tester) async {
    final customer = UserModel(
      id: 1,
      name: 'Rian Saputra',
      email: 'customer@example.com',
      role: 'customer',
      points: 150,
    );

    await SessionManager.saveAuth(token: 'valid_token', user: customer);
    expect(SessionManager.hasToken(), isTrue);

    // Simulasi logout
    await SessionManager.clearAuth();
    expect(SessionManager.hasToken(), isFalse);
    expect(SessionManager.getUser(), isNull);

    // Buka aplikasi setelah logout -> harus ke Landing
    await tester.pumpWidget(const SimaulMobileApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Layanan Perawatan & Servis Terpadu'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
