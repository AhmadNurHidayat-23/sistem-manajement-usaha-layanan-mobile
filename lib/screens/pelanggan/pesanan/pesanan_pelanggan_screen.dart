import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../services/api_service.dart';
import 'detail_pesanan_screen.dart';
import 'widgets/booking_order_card.dart';

class PesananPelangganScreen extends StatefulWidget {
  const PesananPelangganScreen({super.key});

  @override
  State<PesananPelangganScreen> createState() => _PesananPelangganScreenState();
}

class _PesananPelangganScreenState extends State<PesananPelangganScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _bookings = [];
  List<BookingModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final bFuture = ApiService.get(ApiEndpoints.customerBookings);
    final oFuture = ApiService.get(ApiEndpoints.customerOrders);
    final results = await Future.wait([bFuture, oFuture]);

    if (!mounted) return;

    final bRes = results[0];
    final oRes = results[1];

    if (bRes.success && bRes.data is List) {
      _bookings = (bRes.data as List).map((e) => BookingModel.fromBookingJson(e as Map<String, dynamic>)).toList();
    }
    if (oRes.success && oRes.data is List) {
      _orders = (oRes.data as List).map((e) => BookingModel.fromOrderJson(e as Map<String, dynamic>)).toList();
    }

    setState(() {
      _isLoading = false;
      if (!bRes.success && !oRes.success) _errorMessage = bRes.message;
    });
  }

  Widget _buildList(List<BookingModel> list, String emptyMsg) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(emptyMsg, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          return BookingOrderCard(
            item: item,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPesananScreen(item: item))),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryNavy,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryNavy,
            tabs: const [
              Tab(text: 'Booking Layanan'),
              Tab(text: 'Pesanan Drop-off'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(_bookings, 'Belum ada booking layanan.'),
              _buildList(_orders, 'Belum ada pesanan drop-off.'),
            ],
          ),
        ),
      ],
    );
  }
}
