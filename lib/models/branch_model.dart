import '../core/utils/business_name_formatter.dart';

class BranchModel {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? openingTime;
  final String? closingTime;
  final String? serviceMode;
  final int? maxSlotCapacity;

  BranchModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.openingTime,
    this.closingTime,
    this.serviceMode,
    this.maxSlotCapacity,
  });

  String get displayName => BusinessNameFormatter.format(name);

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      serviceMode: json['service_mode']?.toString(),
      maxSlotCapacity: json['max_slot_capacity'] as int?,
    );
  }
}

