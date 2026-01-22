import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service for Supabase operations
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  // Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  // Auth helper
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // ============================================================================
  // AUTH OPERATIONS
  // ============================================================================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // Create profile if signup successful
    if (response.user != null) {
      await client.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'currency': 'NPR',
        'currency_symbol': 'Rs.',
      });
    }

    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ============================================================================
  // PROFILE OPERATIONS
  // ============================================================================

  /// Get current user profile
  Future<Map<String, dynamic>?> getProfile() async {
    if (currentUserId == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .single();

    return response;
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? currency,
    String? currencySymbol,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (currency != null) updates['currency'] = currency;
    if (currencySymbol != null) updates['currency_symbol'] = currencySymbol;

    if (updates.isNotEmpty) {
      await client
          .from('profiles')
          .update(updates)
          .eq('id', currentUserId!);
    }
  }

  // ============================================================================
  // PAYMENT METHOD OPERATIONS
  // ============================================================================

  /// Get all payment methods for current user
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    if (currentUserId == null) return [];

    final response = await client
        .from('payment_methods')
        .select()
        .eq('user_id', currentUserId!)
        .eq('is_active', true)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single payment method
  Future<Map<String, dynamic>?> getPaymentMethod(String id) async {
    final response = await client
        .from('payment_methods')
        .select()
        .eq('id', id)
        .single();

    return response;
  }

  /// Create payment method
  Future<Map<String, dynamic>> createPaymentMethod({
    required String name,
    required String type,
    required String icon,
    double balance = 0.0,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client
        .from('payment_methods')
        .insert({
      'user_id': currentUserId,
      'name': name,
      'type': type,
      'icon': icon,
      'balance': balance,
    })
        .select()
        .single();

    return response;
  }

  /// Update payment method
  Future<void> updatePaymentMethod({
    required String id,
    String? name,
    String? icon,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (icon != null) updates['icon'] = icon;
    if (isActive != null) updates['is_active'] = isActive;

    if (updates.isNotEmpty) {
      await client
          .from('payment_methods')
          .update(updates)
          .eq('id', id);
    }
  }

  /// Delete payment method (soft delete by setting is_active to false)
  Future<void> deletePaymentMethod(String id) async {
    await client
        .from('payment_methods')
        .update({'is_active': false})
        .eq('id', id);
  }

  // ============================================================================
  // CATEGORY OPERATIONS
  // ============================================================================

  /// Get all categories for current user
  Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
    if (currentUserId == null) return [];

    dynamic query = client
        .from('categories')
        .select()
        .eq('user_id', currentUserId!);

    if (type != null) {
      query = query.eq('type', type);
    }

    final response = await query.order('name') as List;

    return List<Map<String, dynamic>>.from(response);
  }

  /// Create custom category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client
        .from('categories')
        .insert({
      'user_id': currentUserId,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'is_default': false,
    })
        .select()
        .single();

    return response;
  }

  // ============================================================================
  // TRANSACTION OPERATIONS
  // ============================================================================

  /// Get transactions with filters
  Future<List<Map<String, dynamic>>> getTransactions({
    String? type,
    String? paymentMethodId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    print('🔍 getTransactions called - currentUserId: $currentUserId');
    if (currentUserId == null) {
      print('❌ currentUserId is NULL in getTransactions');
      return [];
    }

    dynamic query = client
        .from('transactions')
        .select('''
          *,
          payment_methods(id, name, icon, type),
          categories(id, name, icon, color, type)
        ''')
        .eq('user_id', currentUserId!);

    if (type != null) query = query.eq('type', type);
    if (paymentMethodId != null) query = query.eq('payment_method_id', paymentMethodId);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (startDate != null) query = query.gte('transaction_date', startDate.toIso8601String());
    if (endDate != null) query = query.lte('transaction_date', endDate.toIso8601String());

    query = query.order('transaction_date', ascending: false).order('created_at', ascending: false);

    if (limit != null) query = query.limit(limit);

    final response = await query as List;
    print('📊 Supabase returned ${response.length} transactions');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single transaction
  Future<Map<String, dynamic>?> getTransaction(String id) async {
    final response = await client
        .from('transactions')
        .select('''
          *,
          payment_methods(id, name, icon, type),
          categories(id, name, icon, color, type)
        ''')
        .eq('id', id)
        .single();

    return response;
  }

  /// Create transaction
  Future<Map<String, dynamic>> createTransaction({
    required String paymentMethodId,
    required String categoryId,
    required double amount,
    required String type,
    String? description,
    String? notes,
    DateTime? transactionDate,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client
        .from('transactions')
        .insert({
      'user_id': currentUserId,
      'payment_method_id': paymentMethodId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'notes': notes,
      'transaction_date': (transactionDate ?? DateTime.now()).toIso8601String().split('T')[0],
    })
        .select()
        .single();

    return response;
  }

  /// Update transaction
  Future<void> updateTransaction({
    required String id,
    String? paymentMethodId,
    String? categoryId,
    double? amount,
    String? type,
    String? description,
    String? notes,
    DateTime? transactionDate,
  }) async {
    final updates = <String, dynamic>{};
    if (paymentMethodId != null) updates['payment_method_id'] = paymentMethodId;
    if (categoryId != null) updates['category_id'] = categoryId;
    if (amount != null) updates['amount'] = amount;
    if (type != null) updates['type'] = type;
    if (description != null) updates['description'] = description;
    if (notes != null) updates['notes'] = notes;
    if (transactionDate != null) {
      updates['transaction_date'] = transactionDate.toIso8601String().split('T')[0];
    }

    if (updates.isNotEmpty) {
      await client
          .from('transactions')
          .update(updates)
          .eq('id', id);
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    await client
        .from('transactions')
        .delete()
        .eq('id', id);
  }

  // ============================================================================
  // ANALYTICS OPERATIONS
  // ============================================================================

  /// Get total balance across all payment methods
  Future<double> getTotalBalance() async {
    if (currentUserId == null) return 0.0;

    final response = await client
        .from('payment_methods')
        .select('balance')
        .eq('user_id', currentUserId!)
        .eq('is_active', true);

    double total = 0.0;
    for (var method in response) {
      total += (method['balance'] as num).toDouble();
    }

    return total;
  }

  /// Get total spent in a date range
  Future<double> getTotalSpent({DateTime? startDate, DateTime? endDate}) async {
    if (currentUserId == null) return 0.0;

    dynamic query = client
        .from('transactions')
        .select('amount')
        .eq('user_id', currentUserId!)
        .eq('type', 'expense');

    if (startDate != null) query = query.gte('transaction_date', startDate.toIso8601String());
    if (endDate != null) query = query.lte('transaction_date', endDate.toIso8601String());

    final response = await query as List;

    double total = 0.0;
    for (var transaction in response) {
      total += (transaction['amount'] as num).toDouble();
    }

    return total;
  }

  /// Get spending by category
  Future<Map<String, double>> getSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (currentUserId == null) return {};

    dynamic query = client
        .from('transactions')
        .select('amount, categories(name)')
        .eq('user_id', currentUserId!)
        .eq('type', 'expense');

    if (startDate != null) query = query.gte('transaction_date', startDate.toIso8601String());
    if (endDate != null) query = query.lte('transaction_date', endDate.toIso8601String());

    final response = await query as List;

    final Map<String, double> categoryTotals = {};
    for (var transaction in response) {
      final categoryName = transaction['categories']['name'] as String;
      final amount = (transaction['amount'] as num).toDouble();
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0.0) + amount;
    }

    return categoryTotals;
  }
}