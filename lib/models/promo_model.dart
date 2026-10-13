class PromoModel {
  final int id;
  final String code;
  final String name;
  final String discountType; // 'fixed' | 'percent'
  final double discountValue;
  final int? quota;
  final String? startDate;
  final String? endDate;
  final int? branchId;
  final String branchName;

  PromoModel({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.quota,
    this.startDate,
    this.endDate,
    this.branchId,
    required this.branchName,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'fixed',
      discountValue: (json['discount_value'] != null)
          ? double.tryParse(json['discount_value'].toString()) ?? 0.0
          : 0.0,
      quota: json['quota'] is int ? json['quota'] : int.tryParse(json['quota']?.toString() ?? ''),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? ''),
      branchName: json['branch_name']?.toString() ?? 'Semua Cabang',
    );
  }

  String get discountFormatted {
    if (discountType == 'percent') {
      return '${discountValue.toInt()}%';
    }
    return 'Rp ${discountValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
