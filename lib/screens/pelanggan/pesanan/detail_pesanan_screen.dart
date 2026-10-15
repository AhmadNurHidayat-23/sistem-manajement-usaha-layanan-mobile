import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/business_name_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../services/api_service.dart';
import 'pembayaran_qris_screen.dart';
import 'widgets/payment_status_card.dart';

class DetailPesananScreen extends StatefulWidget {
  final BookingModel item;

  const DetailPesananScreen({super.key, required this.item});

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> {
  late BookingModel _item;
  bool _isLoading = false;
  bool _isInitiatingPayment = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final url = _item.type == 'booking'
        ? ApiEndpoints.customerBookingDetail(_item.id)
        : ApiEndpoints.customerOrderDetail(_item.id);

    final res = await ApiService.get(url);
    if (!mounted) return;

    if (res.success && res.data is Map<String, dynamic>) {
      final json = res.data as Map<String, dynamic>;
      setState(() {
        _item = _item.type == 'booking'
            ? BookingModel.fromBookingJson(json)
            : BookingModel.fromOrderJson(json);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePayment() async {
    if (_item.paymentId != null) {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => PembayaranQrisScreen(paymentId: _item.paymentId!)),
      );
      if (success == true) _loadDetail();
      return;
    }

    setState(() => _isInitiatingPayment = true);
    final body = <String, dynamic>{'payment_method': 'qris'};
    if (_item.type == 'booking') {
      body['booking_id'] = _item.id;
    } else {
      body['order_id'] = _item.id;
    }

    final res = await ApiService.post(ApiEndpoints.customerPayments, body: body);
    if (!mounted) return;
    setState(() => _isInitiatingPayment = false);

    if (res.success && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final payId = data['id'] is int ? data['id'] : int.parse(data['id'].toString());
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => PembayaranQrisScreen(paymentId: payId)),
      );
      if (success == true) _loadDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final title = _item.type == 'booking' ? 'Detail Booking' : 'Detail Pesanan';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDetail),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaymentStatusCard(
                paymentStatus: _item.paymentStatus,
                paymentStatusLabel: _item.paymentStatusLabel,
                totalAmount: _item.totalAmount ?? _item.price,
                discountAmount: _item.discountAmount ?? 0.0,
                isInitiating: _isInitiatingPayment,
                onPay: _item.canPay ? _handlePayment : null,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Pekerjaan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildRow('Status', _item.statusLabel, isBold: true),
                      const Divider(height: 20),
                      _buildRow('Layanan', _item.serviceName),
                      const Divider(height: 20),
                      _buildRow('Cabang', BusinessNameFormatter.format(_item.branchName)),
                      if (_item.durationFormatted != null && _item.durationFormatted!.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildRow('Estimasi Durasi', _item.durationFormatted!),
                      ],
                      const Divider(height: 20),
                      _buildRow('Tanggal', _item.date),
                      if (_item.time != null) ...[
                        const Divider(height: 20),
                        _buildRow('Jadwal / Estimasi', _item.time!),
                      ],
                      if (_item.employeeName != null) ...[
                        const Divider(height: 20),
                        _buildRow('Petugas', _item.employeeName!),
                      ],
                      if (_item.quantity != null) ...[
                        const Divider(height: 20),
                        _buildRow('Estimasi Jumlah', '${_item.quantity} ${_item.unit ?? ''}'),
                      ],
                      const Divider(height: 20),
                      _buildRow('Harga Layanan', currencyFormatter.format(_item.price)),
                    ],
                  ),
                ),
              ),
              if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Catatan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_item.notes!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
