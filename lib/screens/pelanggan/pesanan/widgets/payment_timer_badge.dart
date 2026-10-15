import 'package:flutter/material.dart';

class PaymentTimerBadge extends StatelessWidget {
  final String status;
  final String statusLabel;
  final String? expiredAt;

  const PaymentTimerBadge({
    super.key,
    required this.status,
    required this.statusLabel,
    this.expiredAt,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'paid':
      case 'settlement':
      case 'capture':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case 'expire':
      case 'expired':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case 'cancel':
      case 'deny':
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toLowerCase() == 'paid' || status.toLowerCase() == 'settlement'
                ? Icons.check_circle
                : Icons.access_time_rounded,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
