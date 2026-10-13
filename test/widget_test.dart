import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simaul_mobile/core/utils/session_manager.dart';
import 'package:simaul_mobile/main.dart';

void main() {
  testWidgets('App renders splash screen and transitions to landing page, then can open login', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();

    await tester.pumpWidget(const SimaulMobileApp());
    expect(find.text('SIMAUL'), findsOneWidget);

    // Fast-forward past the splash delay (1.8s)
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should transition to LandingScreen
    expect(find.text('Layanan Perawatan & Servis Terpadu'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Jelajahi Katalog Layanan'), findsOneWidget);

    // Tap "Masuk ke Akun" to navigate to LoginScreen
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    // Now on LoginScreen
    expect(find.text('Masuk ke SIMAUL'), findsOneWidget);
  });
}
