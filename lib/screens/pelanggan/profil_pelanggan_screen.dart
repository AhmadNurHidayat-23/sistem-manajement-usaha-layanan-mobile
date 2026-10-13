import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../landing_screen.dart';
import 'membership_screen.dart';
import 'promo_screen.dart';

class ProfilPelangganScreen extends StatefulWidget {
  const ProfilPelangganScreen({super.key});

  @override
  State<ProfilPelangganScreen> createState() => _ProfilPelangganScreenState();
}

class _ProfilPelangganScreenState extends State<ProfilPelangganScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = SessionManager.getUser();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.softBlue,
                  child: Text(
                    (_user?.name.isNotEmpty == true) ? _user!.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.name ?? 'Pengguna',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (_user?.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _user!.phone!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                  title: const Text('Membership & Poin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${_user?.points ?? 0} Poin Loyalty Aktif', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_offer_rounded, color: Colors.orange, size: 24),
                  title: const Text('Promo & Diskon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Katalog kupon & penawaran spesial', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromoScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.link_rounded, color: AppColors.primary),
                  title: const Text('Host Server Backend', style: TextStyle(fontSize: 14)),
                  subtitle: Text(ApiEndpoints.baseUrl, style: const TextStyle(fontSize: 11)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('Versi Aplikasi', style: TextStyle(fontSize: 14)),
                  trailing: const Text('v1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }
}
