import 'package:flutter/material.dart';

class BookingSchedulePicker extends StatelessWidget {
  final String dateText;
  final String timeText;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const BookingSchedulePicker({
    super.key,
    required this.dateText,
    required this.timeText,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(dateText, style: const TextStyle(fontSize: 12)),
            onPressed: onPickDate,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time, size: 16),
            label: Text(timeText, style: const TextStyle(fontSize: 12)),
            onPressed: onPickTime,
          ),
        ),
      ],
    );
  }
}