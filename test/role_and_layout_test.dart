import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simaul_mobile/core/utils/business_name_formatter.dart';
import 'package:simaul_mobile/core/utils/session_manager.dart';
import 'package:simaul_mobile/main.dart';
import 'package:simaul_mobile/models/branch_model.dart';
import 'package:simaul_mobile/models/user_model.dart';
import 'package:simaul_mobile/screens/auth/widgets/demo_account_selector.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
  });

  group('BusinessNameFormatter Tests', () {
    test('Format nama unit usaha resmi SIMAUL', () {
      expect(
        BusinessNameFormatter.format('SIMAUL Barbershop & Studio (Cabang Pusat)'),
        'Barbershop & Studio',
      );
      expect(
        BusinessNameFormatter.format('SIMAUL Laundry & Shoe Care (Cabang Selatan)'),
        'Laundry & Shoe Care',
      );
      expect(
        BusinessNameFormatter.format('SIMAUL Auto Care & Detailing (Cabang Barat)'),
        'Auto Care & Detailing',
      );
    });

    test('BranchModel.displayName menggunakan nama usaha bersih', () {
      final b = BranchModel(
        id: 1,
        name: 'SIMAUL Barbershop & Studio (Cabang Pusat)',
      );
      expect(b.displayName, 'Barbershop & Studio');
    });
  });

  group('Role Separation & Session Tests', () {
    testWidgets('Cold start dalam keadaan login Karyawan -> Tampil Dashboard Karyawan', (WidgetTester tester) async {
      final employee = UserModel(
        id: 6,
        name: 'Dedi Kurniawan',
        email: 'karyawan@simaul.com',
        role: 'employee',
        employeeId: 1,
        branchId: 1,
        branchName: 'SIMAUL Barbershop & Studio (Cabang Pusat)',
      );

      SharedPreferences.setMockInitialValues({
        'auth_token': 'emp_token_xyz',
        'auth_user': jsonEncode(employee.toJson()),
      });
      await SessionManager.init();

      await tester.pumpWidget(const SimaulMobileApp());
      expect(find.text('SIMAUL'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Harus berada di Dashboard Karyawan, BUKAN Pelanggan
      expect(find.text('SIMAUL Petugas'), findsOneWidget);
      expect(find.text('Area Petugas / Karyawan'), findsOneWidget);
      expect(find.text('Dedi Kurniawan'), findsOneWidget);
      // Memiliki tab Shift dan Tugas
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('Tugas'), findsOneWidget);
      // Tidak boleh menampilkan tombol booking milik pelanggan
      expect(find.text('Buat Booking'), findsNothing);
    });

    testWidgets('DemoAccountSelector menggunakan akun karyawan@simaul.com yang valid', (WidgetTester tester) async {
      String? selectedEmail;
      String? selectedPass;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DemoAccountSelector(
              onSelect: (email, pass) {
                selectedEmail = email;
                selectedPass = pass;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Karyawan'));
      await tester.pumpAndSettle();

      expect(selectedEmail, 'karyawan@simaul.com');
      expect(selectedPass, 'password123');
    });
  });
}
