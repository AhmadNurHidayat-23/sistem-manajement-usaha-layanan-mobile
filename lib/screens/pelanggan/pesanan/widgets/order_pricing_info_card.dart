import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/service_model.dart';
import '../../../../widgets/service_image.dart';

class OrderPricingInfoCard extends StatelessWidget {
  final ServiceModel service;

  const OrderPricingInfoCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: service.isWeightBased ? AppColors.softBlue : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: service.isWeightBased ? AppColors.accentBlue.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceImage(
                imageUrl: service.primaryImageUrl,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.isWeightBased
                          ? 'Tarif: ${currency.format(service.price)} / ${service.unit}'
                          : '${currency.format(service.price)} / ${service.unit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (service.isWeightBased) ...[
            const Text(
              'Berat akan ditimbang oleh petugas saat barang diterima di cabang. Total akhir menunggu hasil penimbangan.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
          ],
          if (service.durationFormatted != null && service.durationFormatted!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.primaryNavy),
                const SizedBox(width: 6),
                Text(
                  'Estimasi Pengerjaan: ${service.durationFormatted}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}