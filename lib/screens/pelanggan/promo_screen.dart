import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../models/promo_model.dart';
import '../../services/api_service.dart';
import 'widgets/promo_card.dart';

class PromoScreen extends StatefulWidget {
  final bool isSelectMode;

  const PromoScreen({
    super.key,
    this.isSelectMode = false,
  });

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PromoModel> _promos = [];

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.get(ApiEndpoints.customerPromos);
    if (!mounted) return;

    if (response.success && response.data is List) {
      final list = response.data as List<dynamic>;
      setState(() {
        _promos = list.map((e) => PromoModel.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isSelectMode ? 'Pilih Promo' : 'Promo & Diskon'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPromos,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPromos,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_promos.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.local_offer_outlined, size: 64, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  'Belum ada promo aktif saat ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Silakan cek kembali secara berkala.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _promos.length,
      itemBuilder: (context, index) {
        final promo = _promos[index];
        return PromoCard(
          promo: promo,
          onUse: widget.isSelectMode
              ? () {
                  Navigator.pop(context, promo.code);
                }
              : null,
        );
      },
    );
  }
}
