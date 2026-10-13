class LoyaltyTransactionModel {
  final int id;
  final String type; // 'earned', 'redeemed', 'adjusted'
  final int points;
  final String description;
  final String createdAt;

  LoyaltyTransactionModel({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type']?.toString() ?? 'earned',
      points: json['points'] is int ? json['points'] : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  bool get isEarned => type == 'earned';

  String get pointsBadge => isEarned ? '+$points' : '-$points';
}

class MembershipModel {
  final int id;
  final String memberCode;
  final String joinedAt;
  final String status;
  final int points;
  final List<LoyaltyTransactionModel> recentTransactions;

  MembershipModel({
    required this.id,
    required this.memberCode,
    required this.joinedAt,
    required this.status,
    required this.points,
    required this.recentTransactions,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    final list = json['recent_transactions'] as List<dynamic>? ?? [];
    return MembershipModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      memberCode: json['member_code']?.toString() ?? '',
      joinedAt: json['joined_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      points: json['points'] is int ? json['points'] : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      recentTransactions: list.map((e) => LoyaltyTransactionModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}
