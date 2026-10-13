import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/business_name_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../widgets/status_badge.dart';

class BookingOrderCard extends StatelessWidget {
  final BookingModel item;
  final VoidCallback onTap;

  const BookingOrderCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  StatusBadge(status: item.status, label: item.statusLabel),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.serviceName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Unit: ${BusinessNameFormatter.format(item.branchName)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.durationFormatted != null && item.durationFormatted!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.durationFormatted!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.quantity != null
                        ? '${currencyFormatter.format(item.price)} (${item.quantity} ${item.unit ?? ''})'
                        : currencyFormatter.format(item.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 14),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}