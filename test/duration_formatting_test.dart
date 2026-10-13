import 'package:flutter_test/flutter_test.dart';
import 'package:simaul_mobile/models/booking_model.dart';
import 'package:simaul_mobile/models/employee_task_model.dart';
import 'package:simaul_mobile/models/service_model.dart';

void main() {
  group('Duration Formatting in Models', () {
    test('ServiceModel extracts duration_formatted from API', () {
      final json = {
        'id': 1,
        'name': 'Ganti Oli Mesin',
        'price': 150000,
        'estimated_duration': 45,
        'duration_formatted': '±1 jam',
        'is_weight_based': false,
        'service_type': 'appointment',
      };

      final service = ServiceModel.fromJson(json);
      expect(service.durationFormatted, '±1 jam');
      expect(service.durationFormatted, isNot(contains('menit')));
    });

    test('BookingModel fromBookingJson extracts duration_formatted', () {
      final json = {
        'id': 10,
        'booking_date': '2026-10-10',
        'booking_time': '10:00',
        'status': 'confirmed',
        'status_label': 'Dikonfirmasi',
        'branch': {'name': 'Cabang Utama'},
        'service': {
          'name': 'Servis Rutin',
          'price': 120000,
          'duration_formatted': '±1,5 jam',
        },
      };

      final booking = BookingModel.fromBookingJson(json);
      expect(booking.durationFormatted, '±1,5 jam');
      expect(booking.durationFormatted, isNot(contains('menit')));
    });

    test('BookingModel fromOrderJson extracts duration_formatted', () {
      final json = {
        'id': 20,
        'created_at': '2026-10-10T08:00:00Z',
        'status': 'in_progress',
        'status_label': 'Sedang Dikerjakan',
        'branch': {'name': 'Cabang Laundry'},
        'service': {
          'name': 'Cuci Express',
          'price': 15000,
          'unit': 'kg',
          'duration_formatted': '±1 hari',
        },
      };

      final order = BookingModel.fromOrderJson(json);
      expect(order.durationFormatted, '±1 hari');
      expect(order.durationFormatted, isNot(contains('menit')));
    });

    test('EmployeeTaskModel extracts duration_formatted without raw minutes', () {
      final json = {
        'id': 30,
        'customer_name': 'Budi',
        'service_name': 'Cuci AC',
        'service_duration': '±2 jam',
        'duration_formatted': '±2 jam',
        'booking_date': '2026-10-10',
        'status': 'confirmed',
        'status_label': 'Dikonfirmasi',
      };

      final task = EmployeeTaskModel.fromJson(json);
      expect(task.durationFormatted, '±2 jam');
      expect(task.durationFormatted, isNot(contains('menit')));
    });
  });
}