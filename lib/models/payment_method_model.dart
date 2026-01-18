class PaymentMethod {
  final String id;
  final String userId;
  final String name;
  final String type; // 'ewallet', 'bank', 'cash'
  final String icon;
  final double balance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.balance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if this is an e-wallet
  bool get isEwallet => type == 'ewallet';

  // Check if this is a bank account
  bool get isBank => type == 'bank';

  // Check if this is cash
  bool get isCash => type == 'cash';

  // Format balance with currency
  String formattedBalance(String currencySymbol) {
    return '$currencySymbol ${balance.toStringAsFixed(2)}';
  }

  // Create from JSON (from Supabase)
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      balance: (json['balance'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON (to send to Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'balance': balance,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for easy updates
  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    double? balance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentMethod(id: $id, name: $name, type: $type, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}