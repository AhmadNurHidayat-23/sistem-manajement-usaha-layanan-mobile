import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/business_name_formatter.dart';
import '../../../core/utils/session_manager.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../landing/landing_screen.dart';

class ProfilKaryawanScreen extends StatefulWidget {
  const ProfilKaryawanScreen({super.key});

  @override
  State<ProfilKaryawanScreen> createState() => _ProfilKaryawanScreenState();
}

class _ProfilKaryawanScreenState extends State<ProfilKaryawanScreen> {
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
        content: const Text('Apakah Anda yakin ingin keluar dari akun petugas?'),
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
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.softBlue,
                  child: Text(
                    (_user?.name.isNotEmpty == true) ? _user!.name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.name ?? 'Petugas SIMAUL',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Role: Karyawan / Petugas',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store_rounded, color: AppColors.primaryNavy),
                  title: const Text('Unit Usaha Penugasan', style: TextStyle(fontSize: 14)),
                  subtitle: Text(
                    _user?.branchName != null && _user!.branchName!.isNotEmpty
                        ? BusinessNameFormatter.format(_user!.branchName)
                        : 'Semua Unit Usaha',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.link_rounded, color: AppColors.primaryNavy),
                  title: const Text('Host Server Backend', style: TextStyle(fontSize: 14)),
                  subtitle: Text(ApiEndpoints.baseUrl, style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
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
