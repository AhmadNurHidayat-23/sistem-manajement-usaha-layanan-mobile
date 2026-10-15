import 'package:flutter/material.dart';

class BookingPromoSelector extends StatelessWidget {
  final List<Map<String, dynamic>> promos;
  final Map<String, dynamic>? selectedPromo;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  const BookingPromoSelector({
    super.key,
    required this.promos,
    required this.selectedPromo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (promos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('4. Promo Tersedia (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Map<String, dynamic>?>(
          initialValue: selectedPromo,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Gunakan Promo'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tanpa Promo')),
            ...promos.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    '${p['code']} - ${p['name']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}