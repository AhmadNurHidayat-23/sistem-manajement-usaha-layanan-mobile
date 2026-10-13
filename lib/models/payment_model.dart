class PaymentModel {
  final int id;
  final int? transactionId;
  final String? transactionCode;
  final double amount;
  final double? subtotal;
  final double? discount;
  final String paymentMethod;
  final String status;
  final String statusLabel;
  final String? gatewayReference;
  final String? qrUrl;
  final bool isPaid;
  final bool isFinal;
  final String? paidAt;
  final String? expiredAt;
  final String? createdAt;

  PaymentModel({
    required this.id,
    this.transactionId,
    this.transactionCode,
    required this.amount,
    this.subtotal,
    this.discount,
    required this.paymentMethod,
    required this.status,
    required this.statusLabel,
    this.gatewayReference,
    this.qrUrl,
    required this.isPaid,
    this.isFinal = false,
    this.paidAt,
    this.expiredAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status']?.toString() ?? 'pending';
    final isPaidVal = json['is_paid'] == true || statusVal == 'paid' || statusVal == 'settlement' || statusVal == 'capture';
    final isFinalVal = json['is_final'] == true || isPaidVal || statusVal == 'expire' || statusVal == 'expired' || statusVal == 'cancel' || statusVal == 'deny';

    return PaymentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      transactionId: json['transaction_id'] is int ? json['transaction_id'] : int.tryParse(json['transaction_id']?.toString() ?? ''),
      transactionCode: json['transaction_code']?.toString(),
      amount: (json['amount'] != null) ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      subtotal: (json['subtotal'] != null) ? double.tryParse(json['subtotal'].toString()) : null,
      discount: (json['discount'] != null) ? double.tryParse(json['discount'].toString()) : null,
      paymentMethod: json['payment_method']?.toString() ?? 'qris',
      status: statusVal,
      statusLabel: json['status_label']?.toString() ?? 'Menunggu Pembayaran',
      gatewayReference: json['gateway_reference']?.toString(),
      qrUrl: json['qr_url']?.toString(),
      isPaid: isPaidVal,
      isFinal: isFinalVal,
      paidAt: json['paid_at']?.toString(),
      expiredAt: json['expired_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  String get amountFormatted {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
