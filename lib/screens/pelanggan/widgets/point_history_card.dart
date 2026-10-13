import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/membership_model.dart';

class PointHistoryCard extends StatelessWidget {
  final LoyaltyTransactionModel transaction;

  const PointHistoryCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned = transaction.isEarned;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isEarned ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            child: Icon(
              isEarned ? Icons.arrow_downward : Icons.arrow_upward,
              color: isEarned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty ? transaction.description : (isEarned ? 'Poin Masuk' : 'Poin Ditukar'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.createdAt,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.pointsBadge} Poin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isEarned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}
