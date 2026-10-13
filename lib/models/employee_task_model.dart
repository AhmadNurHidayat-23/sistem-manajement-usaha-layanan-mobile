class EmployeeTaskModel {
  final int id;
  final String customerName;
  final String? customerPhone;
  final String serviceName;
  final String? serviceDuration;
  final String? durationFormatted;
  final String bookingDate;
  final String? bookingTime;
  final String status;
  final String statusLabel;
  final String? branchName;
  final String? notes;
  final String? createdAt;

  EmployeeTaskModel({
    required this.id,
    required this.customerName,
    this.customerPhone,
    required this.serviceName,
    this.serviceDuration,
    this.durationFormatted,
    required this.bookingDate,
    this.bookingTime,
    required this.status,
    required this.statusLabel,
    this.branchName,
    this.notes,
    this.createdAt,
  });

  factory EmployeeTaskModel.fromJson(Map<String, dynamic> json) {
    return EmployeeTaskModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerName: json['customer_name']?.toString() ?? 'Pelanggan',
      customerPhone: json['customer_phone']?.toString(),
      serviceName: json['service_name']?.toString() ?? 'Layanan',
      serviceDuration: json['service_duration']?.toString(),
      durationFormatted: json['duration_formatted']?.toString() ?? json['service_duration']?.toString(),
      bookingDate: json['booking_date']?.toString() ?? '',
      bookingTime: json['booking_time']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Menunggu',
      branchName: json['branch_name']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}