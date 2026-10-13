import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/service_model.dart';

class BookingServiceDropdown extends StatelessWidget {
  final bool isLoading;
  final List<ServiceModel> services;
  final ServiceModel? selectedService;
  final ValueChanged<ServiceModel?> onChanged;

  const BookingServiceDropdown({
    super.key,
    required this.isLoading,
    required this.services,
    required this.selectedService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    }
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
        child: const Text('Tidak ada layanan booking pada cabang ini.', style: TextStyle(fontSize: 12, color: AppColors.warning)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<ServiceModel>(
          initialValue: selectedService,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Pilih Layanan'),
          items: services
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      '${s.name} (${currency.format(s.price)})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        if (selectedService != null && selectedService!.durationFormatted != null) ...[
          const SizedBox(height: 6),
          Text(
            'Durasi: ${selectedService!.durationFormatted!}',
            style: const TextStyle(fontSize: 12, color: AppColors.primaryNavy, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}