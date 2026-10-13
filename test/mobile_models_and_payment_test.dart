import 'package:flutter_test/flutter_test.dart';
import 'package:simaul_mobile/models/booking_model.dart';
import 'package:simaul_mobile/models/employee_task_model.dart';
import 'package:simaul_mobile/models/membership_model.dart';
import 'package:simaul_mobile/models/payment_model.dart';
import 'package:simaul_mobile/models/promo_model.dart';

void main() {
  group('Membership & Loyalty Parsing Tests', () {
    test('parses active membership with loyalty transactions correctly', () {
      final json = {
        'id': 10,
        'member_code': 'MBR-2026-0001',
        'joined_at': '2026-03-01',
        'status': 'active',
        'points': 250,
        'recent_transactions': [
          {
            'id': 101,
            'type': 'earned',
            'points': 100,
            'description': 'Poin dari Servis AC',
            'created_at': '2026-03-02 10:00',
          },
          {
            'id': 102,
            'type': 'redeemed',
            'points': 50,
            'description': 'Tukar voucher diskon 50k',
            'created_at': '2026-03-03 14:00',
          },
        ],
      };

      final membership = MembershipModel.fromJson(json);

      expect(membership.id, 10);
      expect(membership.memberCode, 'MBR-2026-0001');
      expect(membership.joinedAt, '2026-03-01');
      expect(membership.status, 'active');
      expect(membership.isActive, true);
      expect(membership.points, 250);
      expect(membership.recentTransactions.length, 2);

      final txEarned = membership.recentTransactions.first;
      expect(txEarned.isEarned, true);
      expect(txEarned.pointsBadge, '+100');
      expect(txEarned.description, 'Poin dari Servis AC');

      final txRedeemed = membership.recentTransactions.last;
      expect(txRedeemed.isEarned, false);
      expect(txRedeemed.pointsBadge, '-50');
    });
  });

  group('Riwayat Booking & Order Parsing Tests', () {
    test('parses booking model with payment and duration fields', () {
      final json = {
        'id': 42,
        'booking_date': '2026-03-10',
        'booking_time': '10:00',
        'status': 'confirmed',
        'status_label': 'Dikonfirmasi',
        'branch': {'id': 1, 'name': 'Cabang Utama'},
        'service': {
          'id': 5,
          'name': 'Ganti Oli & Tune Up',
          'price': 150000,
          'duration_formatted': '±1,5 jam',
        },
        'payment': {
          'id': 88,
          'status': 'pending',
          'status_label': 'Menunggu Pembayaran',
          'qr_url': 'https://api.sandbox.midtrans.com/qris/sample.png',
        },
        'payment_status': 'pending',
        'payment_status_label': 'Menunggu Pembayaran',
        'total_amount': 150000,
        'discount_amount': 0,
      };

      final booking = BookingModel.fromBookingJson(json);

      expect(booking.id, 42);
      expect(booking.type, 'booking');
      expect(booking.serviceName, 'Ganti Oli & Tune Up');
      expect(booking.branchName, 'Cabang Utama');
      expect(booking.durationFormatted, '±1,5 jam');
      expect(booking.status, 'confirmed');
      expect(booking.statusLabel, 'Dikonfirmasi');
      expect(booking.paymentId, 88);
      expect(booking.paymentStatus, 'pending');
      expect(booking.isPaid, false);
      expect(booking.canPay, true);
      expect(booking.qrUrl, contains('midtrans.com'));
    });

    test('parses order model with quantity and payment status', () {
      final json = {
        'id': 15,
        'created_at': '2026-03-09T08:00:00Z',
        'estimated_finish_at': '2026-03-11T12:00:00Z',
        'status': 'in_progress',
        'status_label': 'Sedang Dikerjakan',
        'estimated_quantity': 5.0,
        'branch': {'id': 2, 'name': 'Cabang Timur'},
        'service': {
          'id': 9,
          'name': 'Cuci Karpet',
          'price': 20000,
          'unit': 'kg',
          'duration_formatted': '±2 hari',
        },
        'payment_status': 'paid',
        'payment_status_label': 'Lunas',
        'total_amount': 100000,
      };

      final order = BookingModel.fromOrderJson(json);

      expect(order.id, 15);
      expect(order.type, 'order');
      expect(order.quantity, 5.0);
      expect(order.unit, 'kg');
      expect(order.isPaid, true);
      expect(order.canPay, false);
    });
  });

  group('Employee Task Model Tests', () {
    test('parses task and formats duration and actions properly', () {
      final json = {
        'id': 7,
        'customer_name': 'Budi Santoso',
        'customer_phone': '08123456789',
        'service_name': 'Detailing Interior Mobil',
        'booking_date': '2026-03-10',
        'booking_time': '14:00',
        'branch_name': 'Cabang Selatan',
        'status': 'confirmed',
        'status_label': 'Dikonfirmasi',
        'duration_formatted': '±2 jam',
        'notes': 'Mohon vacuum bagian bagasi juga.',
      };

      final task = EmployeeTaskModel.fromJson(json);

      expect(task.id, 7);
      expect(task.customerName, 'Budi Santoso');
      expect(task.serviceName, 'Detailing Interior Mobil');
      expect(task.status, 'confirmed');
      expect(task.durationFormatted, '±2 jam');
      expect(task.notes, contains('vacuum'));
    });
  });

  group('Payment Response & Status Mapping Tests', () {
    test('parses payment model correctly and maps settlement to paid and final', () {
      final json = {
        'id': 99,
        'transaction_id': 12,
        'transaction_code': 'TRX-20260310-XYZ123',
        'amount': 250000,
        'subtotal': 300000,
        'discount': 50000,
        'payment_method': 'qris',
        'status': 'settlement',
        'status_label': 'Pembayaran Berhasil',
        'qr_url': 'https://api.sandbox.midtrans.com/qris/qr.png',
        'is_paid': true,
        'is_final': true,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.id, 99);
      expect(payment.transactionCode, 'TRX-20260310-XYZ123');
      expect(payment.amount, 250000);
      expect(payment.amountFormatted, 'Rp 250.000');
      expect(payment.isPaid, true);
      expect(payment.isFinal, true);
      expect(payment.qrUrl, isNotNull);
    });

    test('maps pending status as non-paid and non-final', () {
      final json = {
        'id': 100,
        'amount': 75000,
        'status': 'pending',
        'status_label': 'Menunggu Pembayaran',
        'is_paid': false,
        'is_final': false,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.isPaid, false);
      expect(payment.isFinal, false);
    });

    test('maps expire status as final and non-paid', () {
      final json = {
        'id': 101,
        'amount': 75000,
        'status': 'expire',
        'status_label': 'Kedaluwarsa',
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.isPaid, false);
      expect(payment.isFinal, true);
    });
  });

  group('Promo Model Tests', () {
    test('parses percent and fixed discount promos correctly', () {
      final percentPromo = PromoModel.fromJson({
        'id': 1,
        'code': 'HEMAT20',
        'name': 'Diskon Berkah',
        'discount_type': 'percent',
        'discount_value': 20,
        'branch_name': 'Semua Cabang',
      });

      expect(percentPromo.discountFormatted, '20%');

      final fixedPromo = PromoModel.fromJson({
        'id': 2,
        'code': 'POTONGAN50K',
        'name': 'Potongan Pembukaan',
        'discount_type': 'fixed',
        'discount_value': 50000,
        'branch_name': 'Cabang Utama',
      });

      expect(fixedPromo.discountFormatted, 'Rp 50.000');
    });
  });
}
