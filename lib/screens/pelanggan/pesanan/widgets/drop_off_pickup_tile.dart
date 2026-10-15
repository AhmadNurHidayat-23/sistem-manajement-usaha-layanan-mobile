import 'package:flutter/material.dart';

class DropOffPickupTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DropOffPickupTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text('Opsi Antar-Jemput (Pickup)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: const Text('Petugas mengambil atau mengantar cucian/barang ke lokasi Anda.', style: TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}