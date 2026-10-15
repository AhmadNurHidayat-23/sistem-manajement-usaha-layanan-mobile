import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentStatusCard extends StatelessWidget {
  final String paymentStatus;
  final String paymentStatusLabel;
  final double totalAmount;
  final double discountAmount;
  final bool isInitiating;
  final VoidCallback? onPay;

  const PaymentStatusCard({
    super.key,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.isInitiating = false,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isPaid = paymentStatus == 'paid' || paymentStatus == 'settlement';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  paymentStatusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (discountAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon Promo', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text('-${currencyFormatter.format(discountAmount)}', style: const TextStyle(fontSize: 13, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Tagihan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(
                currencyFormatter.format(totalAmount),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          if (!isPaid && onPay != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isInitiating ? null : onPay,
                icon: isInitiating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.qr_code_2, size: 20),
                label: const Text('Bayar Sekarang (QRIS)'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
