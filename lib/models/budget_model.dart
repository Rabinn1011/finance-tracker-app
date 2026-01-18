import 'category_model.dart';

class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String period; // 'weekly', 'monthly', 'yearly'
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related objects (populated from joins)
  final Category? category;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  // Check if budget is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Check if budget period is weekly
  bool get isWeekly => period == 'weekly';

  // Check if budget period is monthly
  bool get isMonthly => period == 'monthly';

  // Check if budget period is yearly
  bool get isYearly => period == 'yearly';

  // Calculate percentage spent (requires spent amount)
  double percentageSpent(double spent) {
    if (amount == 0) return 0;
    return (spent / amount * 100).clamp(0, 100);
  }

  // Check if budget is exceeded
  bool isExceeded(double spent) {
    return spent > amount;
  }

  // Get remaining budget
  double remaining(double spent) {
    return (amount - spent).clamp(0, amount);
  }

  // Format amount with currency
  String formattedAmount(String currencySymbol) {
    return '$currencySymbol ${amount.toStringAsFixed(2)}';
  }

  // Create from JSON (from Supabase)
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['categories'] != null
          ? Category.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convert to JSON (to send to Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'period': period,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for easy updates
  Budget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, period: $period, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}