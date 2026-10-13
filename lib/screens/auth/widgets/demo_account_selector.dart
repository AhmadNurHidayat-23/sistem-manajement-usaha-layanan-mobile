import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DemoAccountSelector extends StatelessWidget {
  final void Function(String email, String password) onSelect;

  const DemoAccountSelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Pilih Akun Demo Cepat:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.person_outline, size: 16),
              label: const Text('Pelanggan', style: TextStyle(fontSize: 12)),
              onPressed: () => onSelect('customer@example.com', 'password123'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.badge_outlined, size: 16),
              label: const Text('Karyawan', style: TextStyle(fontSize: 12)),
              onPressed: () => onSelect('karyawan@simaul.com', 'password123'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
