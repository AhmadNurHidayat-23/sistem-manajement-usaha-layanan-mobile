import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/business_name_formatter.dart';

class ShiftScheduleView extends StatelessWidget {
  final Map<String, dynamic>? todayShift;
  final List<dynamic> upcomingShifts;
  final Future<void> Function() onRefresh;

  const ShiftScheduleView({
    super.key,
    required this.todayShift,
    required this.upcomingShifts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Shift Hari Ini',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (todayShift != null)
            _buildShiftCard(
              date: todayShift!['shift_date'] ?? 'Hari Ini',
              startTime: todayShift!['start_time'] ?? '-',
              endTime: todayShift!['end_time'] ?? '-',
              branchName: todayShift!['branch_name'],
              status: todayShift!['status'] ?? 'scheduled',
              isToday: true,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.event_busy, color: AppColors.textSecondary, size: 20),
                  SizedBox(width: 10),
                  Text('Tidak ada jadwal shift kerja hari ini.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Jadwal Shift Mendatang',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (upcomingShifts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text('Belum ada jadwal shift mendatang.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            )
          else
            ...upcomingShifts.map((s) {
              final item = s as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildShiftCard(
                  date: item['shift_date'] ?? '-',
                  startTime: item['start_time'] ?? '-',
                  endTime: item['end_time'] ?? '-',
                  branchName: item['branch_name'],
                  status: item['status'] ?? 'scheduled',
                  isToday: false,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildShiftCard({
    required String date,
    required String startTime,
    required String endTime,
    required String? branchName,
    required String status,
    required bool isToday,
  }) {
    final branchFormatted = BusinessNameFormatter.format(branchName);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isToday ? AppColors.accentBlue : AppColors.border, width: isToday ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isToday ? AppColors.softBlue : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: isToday ? AppColors.primaryNavy : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isToday ? AppColors.primaryNavy : AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.green.shade50 : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isToday ? 'Hari Ini' : status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.green.shade700 : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Jam: $startTime - $endTime',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (branchFormatted.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    branchFormatted,
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryNavy, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
