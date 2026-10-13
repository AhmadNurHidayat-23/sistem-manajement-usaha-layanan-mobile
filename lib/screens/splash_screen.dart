import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/session_manager.dart';
import 'landing_screen.dart';
import 'pelanggan/dashboard_pelanggan_screen.dart';
import 'karyawan/dashboard_karyawan_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Tampilkan splash selama sekitar 1.8 detik sambil memeriksa sesi
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    if (SessionManager.hasToken()) {
      final role = SessionManager.getRole();
      if (role == 'customer') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPelangganScreen()),
        );
        return;
      } else if (role == 'employee') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardKaryawanScreen()),
        );
        return;
      } else {
        // Role tidak valid / sesi corrupt -> bersihkan sesi
        await SessionManager.clearAuth();
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.car_repair_rounded,
                size: 64,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SIMAUL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Service Management Application',
              style: TextStyle(
                color: AppColors.softBlue,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
