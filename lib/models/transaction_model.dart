import 'payment_method_model.dart';
import 'category_model.dart';

class Transaction {
  final String id;
  final String userId;
  final String paymentMethodId;
  final String categoryId;
  final double amount;
  final String type; // 'expense' or 'income'
  final String? description;
  final String? notes;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related objects (populated from joins)
  final PaymentMethod? paymentMethod;
  final Category? category;

  Transaction({
    required this.id,
    required this.userId,
    required this.paymentMethodId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    this.notes,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.paymentMethod,
    this.category,
  });

  // Check if this is an expense
  bool get isExpense => type == 'expense';

  // Check if this is income
  bool get isIncome => type == 'income';

  // Format amount with currency
  String formattedAmount(String currencySymbol) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix$currencySymbol ${amount.toStringAsFixed(2)}';
  }

  // Get display date (for UI)
  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(transactionDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${transactionDate.day}/${transactionDate.month}/${transactionDate.year}';
    }
  }

  // Create from JSON (from Supabase)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      paymentMethodId: json['payment_method_id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paymentMethod: json['payment_methods'] != null
          ? PaymentMethod.fromJson(json['payment_methods'] as Map<String, dynamic>)
          : null,
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
      'payment_method_id': paymentMethodId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for easy updates
  Transaction copyWith({
    String? id,
    String? userId,
    String? paymentMethodId,
    String? categoryId,
    double? amount,
    String? type,
    String? description,
    String? notes,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    PaymentMethod? paymentMethod,
    Category? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, date: $transactionDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}