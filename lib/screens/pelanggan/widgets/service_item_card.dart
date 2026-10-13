import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/business_name_formatter.dart';
import '../../../models/service_model.dart';
import '../../../widgets/service_image.dart';

class ServiceItemCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onBookTap;
  final VoidCallback? onTap;

  const ServiceItemCard({
    super.key,
    required this.service,
    this.onBookTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ServiceImage(
                imageUrl: service.primaryImageUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(service.price),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                          ),
                          if (service.unit.isNotEmpty)
                            Text(
                              '/ ',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (service.description != null && service.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (service.durationFormatted != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 12, color: AppColors.primaryNavy),
                              const SizedBox(width: 4),
                              Text(
                                service.durationFormatted!,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryNavy),
                              ),
                            ],
                          ),
                        ),
                      if (service.branchName != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              BusinessNameFormatter.format(service.branchName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      if (onBookTap != null)
                        ElevatedButton(
                          onPressed: onBookTap,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: Text(service.serviceType == 'drop_off' ? 'Drop-off' : 'Booking'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
