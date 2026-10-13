import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  Color _getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
      case 'selesai':
        return AppColors.success;
      case 'in_progress':
      case 'processing':
      case 'diproses':
        return AppColors.accentBlue;
      case 'confirmed':
      case 'dikonfirmasi':
      case 'ready':
      case 'siap diambil':
        return AppColors.info;
      case 'cancelled':
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
