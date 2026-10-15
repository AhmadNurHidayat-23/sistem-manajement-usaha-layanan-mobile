import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/payment_model.dart';
import '../../../services/api_service.dart';
import 'widgets/payment_timer_badge.dart';

class PembayaranQrisScreen extends StatefulWidget {
  final int paymentId;
  final PaymentModel? initialPayment;

  const PembayaranQrisScreen({
    super.key,
    required this.paymentId,
    this.initialPayment,
  });

  @override
  State<PembayaranQrisScreen> createState() => _PembayaranQrisScreenState();
}

class _PembayaranQrisScreenState extends State<PembayaranQrisScreen> {
  PaymentModel? _payment;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollTimer;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPayment != null) {
      _payment = widget.initialPayment;
      _isLoading = false;
      if (!_payment!.isFinal) {
        _startPolling();
      }
    } else {
      _loadPaymentDetail();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPaymentDetail() async {
    final response = await ApiService.get(ApiEndpoints.customerPaymentDetail(widget.paymentId));
    if (!mounted) return;

    if (response.success && response.data is Map<String, dynamic>) {
      setState(() {
        _payment = PaymentModel.fromJson(response.data as Map<String, dynamic>);
        _isLoading = false;
      });
      if (!_payment!.isFinal) {
        _startPolling();
      }
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final response = await ApiService.get(ApiEndpoints.customerPaymentStatus(widget.paymentId));
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (response.success && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final isPaid = data['is_paid'] == true;
        final isFinal = data['is_final'] == true;
        final status = data['status']?.toString() ?? '';
        final statusLabel = data['status_label']?.toString() ?? '';

        if (isPaid || status == 'paid' || status == 'settlement') {
          timer.cancel();
          setState(() {
            _payment = PaymentModel(
              id: widget.paymentId,
              transactionId: _payment?.transactionId,
              transactionCode: _payment?.transactionCode,
              amount: _payment?.amount ?? 0,
              paymentMethod: 'qris',
              status: status,
              statusLabel: statusLabel.isNotEmpty ? statusLabel : 'Pembayaran Berhasil',
              qrUrl: _payment?.qrUrl,
              isPaid: true,
              isFinal: true,
            );
          });
          _showSuccessModal();
        } else if (isFinal) {
          timer.cancel();
          setState(() {
            _payment = PaymentModel(
              id: widget.paymentId,
              transactionId: _payment?.transactionId,
              transactionCode: _payment?.transactionCode,
              amount: _payment?.amount ?? 0,
              paymentMethod: 'qris',
              status: status,
              statusLabel: statusLabel.isNotEmpty ? statusLabel : 'Kadaluarsa',
              qrUrl: _payment?.qrUrl,
              isPaid: false,
              isFinal: true,
            );
          });
        }
      }
    });
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil!'),
          ],
        ),
        content: const Text(
          'Pembayaran QRIS telah kami terima dan diverifikasi. Status pesanan Anda kini telah diperbarui.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('Lihat Pesanan'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulatePayment() async {
    setState(() => _isSimulating = true);
    final response = await ApiService.post(ApiEndpoints.customerPaymentSimulate(widget.paymentId));
    if (!mounted) return;
    setState(() => _isSimulating = false);

    if (response.success) {
      _pollTimer?.cancel();
      _showSuccessModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadPaymentDetail, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final p = _payment!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
                const Text('Total Pembayaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  p.amountFormatted,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                if (p.transactionCode != null) ...[
                  const SizedBox(height: 4),
                  Text('Kode: ${p.transactionCode}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
                const SizedBox(height: 12),
                PaymentTimerBadge(status: p.status, statusLabel: p.statusLabel, expiredAt: p.expiredAt),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                if (p.qrUrl != null && p.qrUrl!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Image.network(
                      p.qrUrl!,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(child: Text('Gagal memuat QR')),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('QR Code tidak tersedia', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Scan QRIS menggunakan GoPay, OVO, Dana, BCA, atau aplikasi m-Banking Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!p.isPaid)
            OutlinedButton.icon(
              onPressed: _isSimulating ? null : _simulatePayment,
              icon: _isSimulating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.flash_on, color: Colors.orange, size: 20),
              label: const Text('Simulasi Bayar Berhasil (Sandbox)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
                side: BorderSide(color: Colors.orange.shade300),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }
}
