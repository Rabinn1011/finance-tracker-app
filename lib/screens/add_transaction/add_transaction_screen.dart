import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/category_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/category_model.dart' as model;
import '../../models/payment_method_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _transactionType = 'expense'; // 'expense' or 'income'
  double _amount = 0.0;
  String _amountDisplay = '0.00';
  model.Category? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false; // Add this to track submission state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final categoryProvider = context.read<CategoryProvider>();
    final paymentProvider = context.read<PaymentMethodProvider>();

    await Future.wait([
      categoryProvider.loadCategories(),
      paymentProvider.loadPaymentMethods(),
    ]);

    // Auto-select first category and payment method
    if (mounted) {
      setState(() {
        final categories = _transactionType == 'expense'
            ? categoryProvider.expenseCategories
            : categoryProvider.incomeCategories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;

        final paymentMethods = paymentProvider.paymentMethods;
        _selectedPaymentMethod = paymentMethods.isNotEmpty ? paymentMethods.first : null;
      });
    }
  }

  void _onNumberTap(String value) {
    setState(() {
      if (value == '⌫') {
        // Backspace
        if (_amountDisplay.length > 1) {
          _amountDisplay = _amountDisplay.substring(0, _amountDisplay.length - 1);
        } else {
          _amountDisplay = '0';
        }
      } else if (value == '.') {
        // Decimal point
        if (!_amountDisplay.contains('.')) {
          _amountDisplay += '.';
        }
      } else {
        // Number
        if (_amountDisplay == '0' || _amountDisplay == '0.00') {
          _amountDisplay = value;
        } else {
          _amountDisplay += value;
        }
      }

      // Update amount
      _amount = double.tryParse(_amountDisplay) ?? 0.0;
    });
  }

  Future<void> _saveTransaction() async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    final transactionProvider = context.read<TransactionProvider>();

    final success = await transactionProvider.createTransaction(
      paymentMethodId: _selectedPaymentMethod!.id,
      categoryId: _selectedCategory!.id,
      amount: _amount,
      type: _transactionType,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      transactionDate: _selectedDate,
    );

    // Reset submitting state
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    if (success && mounted) {
      // Reload payment methods to get updated balance
      await context.read<PaymentMethodProvider>().loadPaymentMethods();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(transactionProvider.errorMessage ?? 'Failed to add transaction'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final paymentProvider = context.watch<PaymentMethodProvider>();

    final categories = _transactionType == 'expense'
        ? categoryProvider.expenseCategories
        : categoryProvider.incomeCategories;

    final paymentMethods = paymentProvider.paymentMethods;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ADD TRANSACTION'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing24),
            child: Column(
              children: [
                // Transaction Type Toggle
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton('Expense', 'expense'),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: _buildTypeButton('Income', 'income'),
                      ),
                    ],
                  ),
                ),

                // Amount Display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENTER AMOUNT',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        'Rs. $_amountDisplay',
                        style: AppTextStyles.amountInput.copyWith(
                          color: _transactionType == 'expense' ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Category Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATEGORY',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = _selectedCategory?.id == category.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: AppConstants.spacing12),
                              child: _buildCategoryButton(category, isSelected),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Payment Method Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYMENT METHOD',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      DropdownButtonFormField<PaymentMethod>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing16,
                            vertical: AppConstants.spacing12,
                          ),
                        ),
                        items: paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing16),

                // Notes Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add a note...',
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLines: 2,
                  ),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Number Pad
                _buildNumberPad(),

                const SizedBox(height: AppConstants.spacing16),

                // Confirm Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveTransaction,
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('CONFIRM TRANSACTION'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type) {
    final isSelected = _transactionType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = type;
          // Reset category when type changes
          final categoryProvider = context.read<CategoryProvider>();
          final categories = type == 'expense'
              ? categoryProvider.expenseCategories
              : categoryProvider.incomeCategories;
          _selectedCategory = categories.isNotEmpty ? categories.first : null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(model.Category category, bool isSelected) {
    final color = _getCategoryColor(category.color);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(AppConstants.spacing8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category.icon),
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              category.name.split(' ').first, // First word only
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          const SizedBox(height: AppConstants.spacing12),
          _buildNumberRow(['4', '5', '6']),
          const SizedBox(height: AppConstants.spacing12),
          _buildNumberRow(['7', '8', '9']),
          const SizedBox(height: AppConstants.spacing12),
          _buildNumberRow(['.', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _onNumberTap(number),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: number == '⌫' ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.account_balance_wallet;
      case 'freelance':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}