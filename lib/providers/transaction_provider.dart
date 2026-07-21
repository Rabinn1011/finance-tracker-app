import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTransactions => _transactions.isNotEmpty;

  // Get recent transactions (limit)
  List<Transaction> getRecent(int limit) {
    return _transactions.take(limit).toList();
  }

  // Get expense transactions
  List<Transaction> get expenses {
    return _transactions.where((t) => t.isExpense).toList();
  }

  // Get income transactions
  List<Transaction> get income {
    return _transactions.where((t) => t.isIncome).toList();
  }

  // Get total expenses
  double get totalExpenses {
    return expenses.fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get total income
  double get totalIncome {
    return income.fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get transaction by ID
  Transaction? getById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch transactions without touching shared state.
  ///
  /// Use this for screen-local, filtered views (a single category, a single
  /// payment method, a search result). Writing those into [_transactions]
  /// would corrupt every other screen reading the shared list.
  Future<List<Transaction>> fetchTransactions({
    String? type,
    String? paymentMethodId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final currentUserId = SupabaseService.instance.currentUserId;
    print('🔍 Fetching transactions for user: $currentUserId');

    if (currentUserId == null) {
      print('❌ USER ID IS NULL - Cannot fetch transactions');
      return [];
    }

    final data = await _supabaseService.getTransactions(
      type: type,
      paymentMethodId: paymentMethodId,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );

    print('📦 Raw data from Supabase: ${data.length} items');
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  // Load transactions with filters into the shared list.
  // Only screens showing the user's whole picture (home, analytics) should
  // call this; filtered views should use [fetchTransactions] instead.
  Future<void> loadTransactions({
    String? type,
    String? paymentMethodId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _transactions = await fetchTransactions(
        type: type,
        paymentMethodId: paymentMethodId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      print('✅ Loaded ${_transactions.length} transactions into shared state');
    } catch (e) {
      print('❌ Error in loadTransactions: $e');
      _setError('Failed to load transactions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create transaction
  Future<bool> createTransaction({
    required String paymentMethodId,
    required String categoryId,
    required double amount,
    required String type,
    String? description,
    String? notes,
    DateTime? transactionDate,
  }) async {
    _clearError();

    try {
      final data = await _supabaseService.createTransaction(
        paymentMethodId: paymentMethodId,
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        notes: notes,
        transactionDate: transactionDate,
      );

      // Get the transaction ID from the created transaction
      final transactionId = data['id'] as String;

      // Fetch the complete transaction with joins
      final completeTransaction = await _supabaseService.getTransaction(transactionId);

      if (completeTransaction != null) {
        final newTransaction = Transaction.fromJson(completeTransaction);
        _transactions.insert(0, newTransaction);
        notifyListeners();
        return true;
      } else {
        // Fallback: use the basic data if fetch fails
        final newTransaction = Transaction.fromJson(data);
        _transactions.insert(0, newTransaction);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError('Failed to create transaction: ${e.toString()}');
      return false;
    }
  }

  // Update transaction
  Future<bool> updateTransaction({
    required String id,
    String? paymentMethodId,
    String? categoryId,
    double? amount,
    String? type,
    String? description,
    String? notes,
    DateTime? transactionDate,
  }) async {
    _clearError();

    try {
      await _supabaseService.updateTransaction(
        id: id,
        paymentMethodId: paymentMethodId,
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        notes: notes,
        transactionDate: transactionDate,
      );

      // Reload to get updated data with relationships
      await loadTransactions();
      return true;
    } catch (e) {
      _setError('Failed to update transaction: ${e.toString()}');
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String id) async {
    _clearError();

    try {
      await _supabaseService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: ${e.toString()}');
      return false;
    }
  }

  // Get transactions for a specific date range
  Future<void> loadTransactionsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await loadTransactions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get transactions for current week
  Future<void> loadWeeklyTransactions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    await loadTransactionsForDateRange(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  // Get transactions for current month
  Future<void> loadMonthlyTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    await loadTransactionsForDateRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  // Get transactions for current year
  Future<void> loadYearlyTransactions() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    await loadTransactionsForDateRange(
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }

  // Refresh data from server
  Future<void> refresh() async {
    await loadTransactions();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Clear all data (on logout)
  void clear() {
    _transactions = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}