import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.car_repair_rounded, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Masuk ke SIMAUL',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Aplikasi Mobile Layanan & Tugas Petugas',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}