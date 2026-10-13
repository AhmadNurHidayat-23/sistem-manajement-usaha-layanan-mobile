import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../models/branch_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'buat_booking_screen.dart';
import 'buat_pesanan_screen.dart';
import 'katalog_layanan_screen.dart';
import 'membership_screen.dart';
import 'pesanan_pelanggan_screen.dart';
import 'profil_pelanggan_screen.dart';
import 'promo_screen.dart';
import 'widgets/branch_card.dart';
import 'widgets/welcome_loyalty_card.dart';

class DashboardPelangganScreen extends StatefulWidget {
  const DashboardPelangganScreen({super.key});

  @override
  State<DashboardPelangganScreen> createState() => _DashboardPelangganScreenState();
}

class _DashboardPelangganScreenState extends State<DashboardPelangganScreen> {
  int _currentIndex = 0;
  UserModel? _user;
  List<BranchModel> _branches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _user = SessionManager.getUser();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.get(ApiEndpoints.branches);
    if (!mounted) return;

    if (res.success && res.data is List) {
      final list = (res.data as List).map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        _branches = list;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res.message;
      });
    }
  }

  Widget _buildHomeView() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen())),
              child: WelcomeLoyaltyCard(user: _user),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    title: 'Buat Booking',
                    subtitle: 'Janji Temu',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatBookingScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    title: 'Drop-off Pesanan',
                    subtitle: 'Laundry & Cuci',
                    icon: Icons.local_laundry_service_rounded,
                    color: AppColors.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatPesananScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    title: 'Promo & Diskon',
                    subtitle: 'Kupon Spesial',
                    icon: Icons.local_offer_rounded,
                    color: Colors.orange.shade800,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromoScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    title: 'Membership & Poin',
                    subtitle: 'Loyalty Rewards',
                    icon: Icons.card_membership_rounded,
                    color: Colors.indigo.shade800,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Layanan Usaha Tersedia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    TextButton(onPressed: _loadDashboardData, child: const Text('Coba Lagi')),
                  ],
                ),
              )
            else if (_branches.isEmpty)
              const Center(child: Text('Tidak ada cabang tersedia.'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _branches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) => BranchCard(branch: _branches[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeView(),
      const KatalogLayananScreen(),
      const PesananPelangganScreen(),
      const ProfilPelangganScreen(),
    ];

    final titles = ['SIMAUL', 'Katalog Layanan', 'Pesanan & Booking', 'Profil Pelanggan'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Layanan'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
