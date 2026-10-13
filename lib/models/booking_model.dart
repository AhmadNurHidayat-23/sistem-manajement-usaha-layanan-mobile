class BookingModel {
  final int id;
  final String type; // 'booking' atau 'order'
  final String date;
  final String? time;
  final String status;
  final String statusLabel;
  final String branchName;
  final String serviceName;
  final double price;
  final String? durationFormatted;
  final String? notes;
  final String? employeeName;
  final double? quantity;
  final String? unit;
  final int? paymentId;
  final String paymentStatus;
  final String paymentStatusLabel;
  final double? totalAmount;
  final double? discountAmount;
  final String? qrUrl;

  BookingModel({
    required this.id,
    required this.type,
    required this.date,
    this.time,
    required this.status,
    required this.statusLabel,
    required this.branchName,
    required this.serviceName,
    required this.price,
    this.durationFormatted,
    this.notes,
    this.employeeName,
    this.quantity,
    this.unit,
    this.paymentId,
    this.paymentStatus = 'unpaid',
    this.paymentStatusLabel = 'Belum Dibayar',
    this.totalAmount,
    this.discountAmount,
    this.qrUrl,
  });

  bool get isPaid => paymentStatus == 'paid' || paymentStatus == 'settlement';
  bool get canPay => !isPaid && status != 'cancelled';

  factory BookingModel.fromBookingJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>?;
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: 'booking',
      date: json['booking_date']?.toString() ?? '',
      time: json['booking_time']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Menunggu',
      branchName: json['branch']?['name']?.toString() ?? '-',
      serviceName: json['service']?['name']?.toString() ?? '-',
      price: (json['service']?['price'] != null) ? double.tryParse(json['service']['price'].toString()) ?? 0.0 : 0.0,
      durationFormatted: json['service']?['duration_formatted']?.toString(),
      notes: json['notes']?.toString(),
      employeeName: json['employee']?['name']?.toString(),
      paymentId: payment?['id'] is int ? payment!['id'] : int.tryParse(payment?['id']?.toString() ?? ''),
      paymentStatus: json['payment_status']?.toString() ?? payment?['status']?.toString() ?? 'unpaid',
      paymentStatusLabel: json['payment_status_label']?.toString() ?? payment?['status_label']?.toString() ?? 'Belum Dibayar',
      totalAmount: (json['total_amount'] != null) ? double.tryParse(json['total_amount'].toString()) : null,
      discountAmount: (json['discount_amount'] != null) ? double.tryParse(json['discount_amount'].toString()) : null,
      qrUrl: payment?['qr_url']?.toString(),
    );
  }

  factory BookingModel.fromOrderJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>?;
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: 'order',
      date: json['created_at'] != null ? json['created_at'].toString().split('T').first : '',
      time: json['estimated_finish_at'] != null ? 'Selesai: ${json['estimated_finish_at'].toString().split('T').first}' : null,
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Menunggu',
      branchName: json['branch']?['name']?.toString() ?? '-',
      serviceName: json['service']?['name']?.toString() ?? '-',
      price: (json['service']?['price'] != null) ? double.tryParse(json['service']['price'].toString()) ?? 0.0 : 0.0,
      durationFormatted: json['service']?['duration_formatted']?.toString(),
      notes: json['notes']?.toString(),
      quantity: (json['estimated_quantity'] != null) ? double.tryParse(json['estimated_quantity'].toString()) : null,
      unit: json['service']?['unit']?.toString() ?? 'kg',
      paymentId: payment?['id'] is int ? payment!['id'] : int.tryParse(payment?['id']?.toString() ?? ''),
      paymentStatus: json['payment_status']?.toString() ?? payment?['status']?.toString() ?? 'unpaid',
      paymentStatusLabel: json['payment_status_label']?.toString() ?? payment?['status_label']?.toString() ?? 'Belum Dibayar',
      totalAmount: (json['total_amount'] != null) ? double.tryParse(json['total_amount'].toString()) : null,
      discountAmount: (json['discount_amount'] != null) ? double.tryParse(json['discount_amount'].toString()) : null,
      qrUrl: payment?['qr_url']?.toString(),
    );
  }
}
