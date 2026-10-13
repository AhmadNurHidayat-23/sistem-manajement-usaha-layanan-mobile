import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/business_name_formatter.dart';
import '../../models/service_model.dart';
import '../../widgets/service_image.dart';
import 'buat_booking_screen.dart';
import 'buat_pesanan_screen.dart';

class DetailLayananScreen extends StatefulWidget {
  final ServiceModel service;

  const DetailLayananScreen({super.key, required this.service});

  @override
  State<DetailLayananScreen> createState() => _DetailLayananScreenState();
}

class _DetailLayananScreenState extends State<DetailLayananScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBook() {
    final s = widget.service;
    final isDropOff = s.serviceType == 'drop_off' || s.isWeightBased;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isDropOff
            ? BuatPesananScreen(initialBranchId: s.branchId, initialServiceId: s.id)
            : BuatBookingScreen(initialBranchId: s.branchId, initialServiceId: s.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final images = s.images.isNotEmpty
        ? s.images
        : (s.imageUrl != null && s.imageUrl!.isNotEmpty ? [s.imageUrl!] : <String>[]);

    return Scaffold(
      appBar: AppBar(title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: (idx) => setState(() => _currentIndex = idx),
                    itemBuilder: (_, index) => ServiceImage(
                      imageUrl: images.isNotEmpty ? images[index] : null,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ' / ',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == i ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == i ? AppColors.primaryNavy : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(s.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(currency.format(s.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                          if (s.unit.isNotEmpty)
                            Text('/ ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (s.durationFormatted != null)
                        Chip(
                          avatar: const Icon(Icons.schedule, size: 16, color: AppColors.primaryNavy),
                          label: Text(s.durationFormatted!),
                          backgroundColor: AppColors.softBlue,
                        ),
                      if (s.categoryName != null)
                        Chip(
                          avatar: const Icon(Icons.category_outlined, size: 16, color: AppColors.textSecondary),
                          label: Text(s.categoryName!),
                          backgroundColor: AppColors.background,
                        ),
                      if (s.branchName != null)
                        Chip(
                          avatar: const Icon(Icons.store_outlined, size: 16, color: AppColors.textSecondary),
                          label: Text(BusinessNameFormatter.format(s.branchName)),
                          backgroundColor: AppColors.background,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Deskripsi Layanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    (s.description != null && s.description!.isNotEmpty)
                        ? s.description!
                        : 'Layanan profesional dengan standar kualitas terbaik SIMAUL.',
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _onBook,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              s.serviceType == 'drop_off' || s.isWeightBased ? 'Pesan Drop-off Sekarang' : 'Booking Jadwal Sekarang',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
