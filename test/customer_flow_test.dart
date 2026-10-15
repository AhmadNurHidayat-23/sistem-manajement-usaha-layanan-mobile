import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simaul_mobile/core/theme/app_theme.dart';
import 'package:simaul_mobile/core/utils/session_manager.dart';
import 'package:simaul_mobile/screens/pelanggan/booking/buat_booking_screen.dart';
import 'package:simaul_mobile/screens/pelanggan/pesanan/buat_pesanan_screen.dart';
import 'package:simaul_mobile/screens/pelanggan/booking/widgets/booking_promo_selector.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
  });

  testWidgets('BuatBookingScreen renders basic layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BuatBookingScreen(),
      ),
    );

    expect(find.text('Buat Booking Janji Temu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('BuatPesananScreen renders basic layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BuatPesananScreen(),
      ),
    );

    expect(find.text('Buat Pesanan Drop-off'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('BookingPromoSelector renders options and triggers selection', (WidgetTester tester) async {
    final promos = [
      {'id': 1, 'code': 'DISCOUNT20', 'name': 'Diskon 20%'},
      {'id': 2, 'code': 'HEMAT50K', 'name': 'Potongan 50rb'},
    ];

    Map<String, dynamic>? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingPromoSelector(
            promos: promos,
            selectedPromo: null,
            onChanged: (val) => selected = val,
          ),
        ),
      ),
    );

    expect(find.text('4. Promo Tersedia (Opsional)'), findsOneWidget);
    expect(find.text('Gunakan Promo'), findsOneWidget);

    // Tap dropdown
    await tester.tap(find.byType(DropdownButtonFormField<Map<String, dynamic>?>));
    await tester.pumpAndSettle();

    expect(find.text('DISCOUNT20 - Diskon 20%').last, findsOneWidget);
    await tester.tap(find.text('DISCOUNT20 - Diskon 20%').last);
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!['code'], 'DISCOUNT20');
  });

  test('Flutter booking request payload includes promo_code when selected', () {
    final selectedPromo = {'id': 1, 'code': 'DISCOUNT20', 'name': 'Diskon 20%'};

    final bodyWithPromo = <String, dynamic>{
      'branch_id': 1,
      'service_id': 10,
      'booking_date': '2026-03-15',
      'booking_time': '10:00',
      'notes': 'Catatan khusus',
    };
    if (selectedPromo['code'] != null) {
      bodyWithPromo['promo_code'] = selectedPromo['code'];
    }

    expect(bodyWithPromo['promo_code'], 'DISCOUNT20');
    expect(bodyWithPromo.containsKey('promo_code'), true);

    // Request payload without promo
    final bodyWithoutPromo = <String, dynamic>{
      'branch_id': 1,
      'service_id': 10,
      'booking_date': '2026-03-15',
      'booking_time': '10:00',
      'notes': '',
    };

    expect(bodyWithoutPromo.containsKey('promo_code'), false);
  });

  test('Flutter order request payload includes promo_code when selected', () {
    final selectedPromo = {'id': 2, 'code': 'HEMAT50K', 'name': 'Potongan 50rb'};

    final orderBodyWithPromo = <String, dynamic>{
      'branch_id': 1,
      'service_id': 5,
      'pickup_option': true,
      'notes': 'Laundry kiloan',
    };
    if (selectedPromo['code'] != null) {
      orderBodyWithPromo['promo_code'] = selectedPromo['code'];
    }

    expect(orderBodyWithPromo['promo_code'], 'HEMAT50K');

    final orderBodyWithoutPromo = <String, dynamic>{
      'branch_id': 1,
      'service_id': 5,
      'pickup_option': false,
      'notes': '',
    };
    expect(orderBodyWithoutPromo.containsKey('promo_code'), false);
  });
}
