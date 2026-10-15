import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/membership_model.dart';

class MembershipSummaryCard extends StatelessWidget {
  final MembershipModel? membership;
  final VoidCallback? onRegister;
  final bool isRegistering;

  const MembershipSummaryCard({
    super.key,
    required this.membership,
    this.onRegister,
    this.isRegistering = false,
  });

  @override
  Widget build(BuildContext context) {
    if (membership == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.card_membership, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Belum Terdaftar Member',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Daftar member sekarang untuk mengumpulkan poin loyalty di setiap transaksi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRegistering ? null : onRegister,
                child: isRegistering
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Daftar Member Gratis'),
              ),
            ),
          ],
        ),
      );
    }

    final m = membership!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SIMAUL MEMBER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: m.isActive ? Colors.green.shade600 : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  m.isActive ? 'Aktif' : m.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'TOTAL POIN LOYALTY',
            style: TextStyle(color: AppColors.softBlue, fontSize: 12, letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          Text(
            '${m.points} Pts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kode: ${m.memberCode}',
                style: const TextStyle(
                  color: AppColors.softBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (m.joinedAt.isNotEmpty)
                Text(
                  'Sejak: ${m.joinedAt}',
                  style: const TextStyle(color: AppColors.softBlue, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
