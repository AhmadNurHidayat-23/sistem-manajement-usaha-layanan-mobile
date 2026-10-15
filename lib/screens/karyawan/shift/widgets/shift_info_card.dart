import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/business_name_formatter.dart';
import '../../../../models/user_model.dart';

class ShiftInfoCard extends StatelessWidget {
  final UserModel? user;
  final Map<String, dynamic>? todayShift;

  const ShiftInfoCard({super.key, required this.user, required this.todayShift});

  @override
  Widget build(BuildContext context) {
    final branchFormatted = BusinessNameFormatter.format(user?.branchName);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Area Petugas / Karyawan', style: TextStyle(color: AppColors.softBlue, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Petugas',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (branchFormatted.isNotEmpty) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      branchFormatted,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  todayShift != null
                      ? 'Shift Hari Ini: ${todayShift!['start_time'] ?? '-'} - ${todayShift!['end_time'] ?? '-'}'
                      : 'Tidak ada jadwal shift hari ini.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
