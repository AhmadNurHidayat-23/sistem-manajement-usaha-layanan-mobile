class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int? employeeId;
  final int? branchId;
  final String? branchName;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.employeeId,
    this.branchId,
    this.branchName,
    this.points = 0,
  });

  bool get isCustomer => role == 'customer';
  bool get isEmployee => role == 'employee';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: (json['role'] != null && json['role'].toString().isNotEmpty)
          ? json['role'].toString()
          : ((json['employee_id'] != null || json['employee'] != null) ? 'employee' : 'customer'),
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : (json['employee']?['id'] as int?),
      branchId: json['branch_id'] is int ? json['branch_id'] : (json['employee']?['branch_id'] as int?),
      branchName: json['branch_name']?.toString() ?? json['employee']?['branch_name']?.toString(),
      points: (json['membership']?['points'] as int?) ?? (json['points'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'employee_id': employeeId,
      'branch_id': branchId,
      'branch_name': branchName,
      'points': points,
    };
  }
}
