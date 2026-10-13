import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../services/api_service.dart';
import '../../core/utils/session_manager.dart';
import '../auth/login_screen.dart';
import 'buat_booking_screen.dart';
import 'buat_pesanan_screen.dart';
import 'detail_layanan_screen.dart';
import 'widgets/service_item_card.dart';

class KatalogLayananScreen extends StatefulWidget {
  final bool showAppBar;
  const KatalogLayananScreen({super.key, this.showAppBar = false});

  @override
  State<KatalogLayananScreen> createState() => _KatalogLayananScreenState();
}

class _KatalogLayananScreenState extends State<KatalogLayananScreen> {
  final _searchController = TextEditingController();
  List<ServiceModel> _services = [];
  List<BranchModel> _branches = [];
  int? _selectedBranchId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    final res = await ApiService.get(ApiEndpoints.branches);
    if (res.success && res.data is List && mounted) {
      setState(() {
        _branches = (res.data as List).map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String url = ApiEndpoints.services;
    final params = <String>[];
    if (_selectedBranchId != null) params.add('branch_id=');
    if (_searchController.text.trim().isNotEmpty) params.add('q=');
    if (params.isNotEmpty) url += '?';

    final res = await ApiService.get(url);
    if (!mounted) return;

    if (res.success && res.data is List) {
      setState(() {
        _services = (res.data as List).map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res.message;
      });
    }
  }

  void _onBookService(ServiceModel s) {
    if (!SessionManager.hasToken()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primaryNavy, size: 22),
              SizedBox(width: 8),
              Text('Perlu Masuk Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Untuk memesan atau reservasi layanan "${s.name}", silakan masuk ke akun SIMAUL terlebih dahulu.',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Masuk Sekarang'),
            ),
          ],
        ),
      );
      return;
    }

    if (s.serviceType == 'drop_off' || s.isWeightBased) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BuatPesananScreen(initialBranchId: s.branchId, initialServiceId: s.id)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BuatBookingScreen(initialBranchId: s.branchId, initialServiceId: s.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari layanan...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _loadServices();
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _loadServices(),
              ),
              const SizedBox(height: 8),
              if (_branches.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Semua Cabang', style: TextStyle(fontSize: 12)),
                        selected: _selectedBranchId == null,
                        onSelected: (_) {
                          setState(() => _selectedBranchId = null);
                          _loadServices();
                        },
                      ),
                      const SizedBox(width: 6),
                      ..._branches.map((b) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(b.displayName, style: const TextStyle(fontSize: 12)),
                              selected: _selectedBranchId == b.id,
                              onSelected: (val) {
                                setState(() => _selectedBranchId = val ? b.id : null);
                                _loadServices();
                              },
                            ),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadServices,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            ElevatedButton(onPressed: _loadServices, child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : _services.isEmpty
                        ? const Center(child: Text('Tidak ada layanan yang sesuai.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _services.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, index) => ServiceItemCard(
                              service: _services[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailLayananScreen(service: _services[index]),
                                ),
                              ),
                              onBookTap: () => _onBookService(_services[index]),
                            ),
                          ),
          ),
        ),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Katalog Layanan'),
        ),
        body: content,
      );
    }

    return content;
  }
}
