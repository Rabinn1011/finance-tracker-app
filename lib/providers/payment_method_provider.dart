import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/payment_method_model.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPaymentMethods => _paymentMethods.isNotEmpty;

  // Get total balance across all payment methods
  double get totalBalance {
    return _paymentMethods.fold(0.0, (sum, method) => sum + method.safeBalance);
  }

  // Get payment method by ID
  PaymentMethod? getById(String id) {
    try {
      return _paymentMethods.firstWhere((method) => method.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get payment methods by type
  List<PaymentMethod> getByType(String type) {
    return _paymentMethods.where((method) => method.type == type).toList();
  }

  // Load all payment methods
  Future<void> loadPaymentMethods() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _supabaseService.getPaymentMethods();
      _paymentMethods = data.map((json) => PaymentMethod.fromJson(json)).toList();
    } catch (e) {
      _setError('Failed to load payment methods: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create payment method
  Future<bool> createPaymentMethod({
    required String name,
    required String type,
    required String icon,
    double balance = 0.0,
  }) async {
    _clearError();

    try {
      final data = await _supabaseService.createPaymentMethod(
        name: name,
        type: type,
        icon: icon,
        balance: balance,
      );

      final newMethod = PaymentMethod.fromJson(data);
      _paymentMethods.add(newMethod);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create payment method: ${e.toString()}');
      return false;
    }
  }

  // Update payment method
  Future<bool> updatePaymentMethod({
    required String id,
    String? name,
    String? icon,
    bool? isActive,
  }) async {
    _clearError();

    try {
      await _supabaseService.updatePaymentMethod(
        id: id,
        name: name,
        icon: icon,
        isActive: isActive,
      );

      // Reload to get updated data
      await loadPaymentMethods();
      return true;
    } catch (e) {
      _setError('Failed to update payment method: ${e.toString()}');
      return false;
    }
  }

  // Delete payment method (soft delete)
  Future<bool> deletePaymentMethod(String id) async {
    _clearError();

    try {
      await _supabaseService.deletePaymentMethod(id);
      _paymentMethods.removeWhere((method) => method.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete payment method: ${e.toString()}');
      return false;
    }
  }

  // Refresh data from server
  Future<void> refresh() async {
    await loadPaymentMethods();
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
    _paymentMethods = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}