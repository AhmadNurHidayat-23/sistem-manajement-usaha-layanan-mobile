import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/business_name_formatter.dart';
import '../../../../models/service_model.dart';
import '../../../../widgets/service_image.dart';

class BookingSummaryCard extends StatelessWidget {
  final ServiceModel? service;
  final String dateFormatted;
  final String timeFormatted;

  const BookingSummaryCard({
    super.key,
    required this.service,
    required this.dateFormatted,
    required this.timeFormatted,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (service == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan Janji Temu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                ServiceImage(
                  imageUrl: service!.primaryImageUrl,
                  width: 52,
                  height: 52,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service!.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      if (service!.branchName != null)
                        Text(
                          BusinessNameFormatter.format(service!.branchName),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (service!.durationFormatted != null && service!.durationFormatted!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimasi Durasi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Flexible(
                    child: Text(
                      service!.durationFormatted!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jadwal', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Flexible(
                  child: Text(
                    '$dateFormatted • $timeFormatted',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Biaya Layanan', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text(
                  currency.format(service!.price),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}