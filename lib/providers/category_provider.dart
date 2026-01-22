import 'package:flutter/foundation.dart' hide Category;
import '../services/supabase_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get expense categories
  List<Category> get expenseCategories {
    return _categories.where((cat) => cat.isExpense).toList();
  }

  // Get income categories
  List<Category> get incomeCategories {
    return _categories.where((cat) => cat.isIncome).toList();
  }

  // Get default categories
  List<Category> get defaultCategories {
    return _categories.where((cat) => cat.safeIsDefault).toList();
  }

  // Get custom categories
  List<Category> get customCategories {
    return _categories.where((cat) => !cat.safeIsDefault).toList();
  }

  // Get category by ID
  Category? getById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load all categories
  Future<void> loadCategories({String? type}) async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _supabaseService.getCategories(type: type);
      _categories = data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create custom category
  Future<bool> createCategory({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    _clearError();

    try {
      final data = await _supabaseService.createCategory(
        name: name,
        icon: icon,
        color: color,
        type: type,
      );

      final newCategory = Category.fromJson(data);
      _categories.add(newCategory);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create category: ${e.toString()}');
      return false;
    }
  }

  // Refresh data from server
  Future<void> refresh() async {
    await loadCategories();
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
    _categories = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}