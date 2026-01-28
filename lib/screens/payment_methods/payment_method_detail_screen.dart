import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/payment_method_model.dart';
import '../../routes/app_routes.dart';

class PaymentMethodDetailScreen extends StatefulWidget {
  final String paymentMethodId;

  const PaymentMethodDetailScreen({
    super.key,
    required this.paymentMethodId,
  });

  @override
  State<PaymentMethodDetailScreen> createState() => _PaymentMethodDetailScreenState();
}

class _PaymentMethodDetailScreenState extends State<PaymentMethodDetailScreen> {
  PaymentMethod? _paymentMethod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final paymentProvider = context.read<PaymentMethodProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    // Load payment method details
    final method = paymentProvider.getById(widget.paymentMethodId);

    // Load all transactions for this payment method
    await transactionProvider.loadTransactions(
      paymentMethodId: widget.paymentMethodId,
    );

    setState(() {
      _paymentMethod = method;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final user = authProvider.userProfile;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Payment Method Details'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_paymentMethod == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Payment Method Details'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Payment method not found',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final method = _paymentMethod!;
    final transactions = transactionProvider.transactions;

    // Calculate totals
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Calculate category breakdown for expenses
    final categoryTotals = <String, double>{};
    for (var transaction in transactions.where((t) => t.isExpense)) {
      final categoryName = transaction.category?.name ?? 'Other';
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + transaction.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(method.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getMethodColor(method.type),
                        _getMethodColor(method.type).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getMethodIcon(method.type),
                        color: AppColors.textOnDark,
                        size: 48,
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'CURRENT BALANCE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        '${user?.currencySymbol ?? 'Rs.'} ${method.safeBalance.toStringAsFixed(2)}',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        _getMethodTypeName(method.type),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Summary Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Income',
                        totalIncome,
                        AppColors.success,
                        Icons.arrow_downward,
                        user?.currencySymbol ?? 'Rs.',
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Expense',
                        totalExpense,
                        AppColors.error,
                        Icons.arrow_upward,
                        user?.currencySymbol ?? 'Rs.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing24),
            ),

            // Spending Breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Text(
                  'SPENDING BY CATEGORY',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing16),
            ),

            // Category Breakdown
            if (sortedCategories.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacing32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppConstants.spacing12),
                          Text(
                            'No expenses yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = sortedCategories[index];
                    final percentage = totalExpense > 0 ? (category.value / totalExpense * 100) : 0;
                    final color = _getCategoryColor(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing24,
                        vertical: AppConstants.spacing8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacing8),
                                  Text(
                                    category.key,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                              Text(
                                '${user?.currencySymbol ?? 'Rs.'} ${category.value.toStringAsFixed(2)}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: color.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing8),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: sortedCategories.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing24),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT TRANSACTIONS',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (transactions.length > 5)
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.transactions);
                        },
                        child: Text(
                          'SEE ALL',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing12),
            ),

            // Transactions List
            if (transactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacing32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppConstants.spacing12),
                          Text(
                            'No transactions yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final transaction = transactions[index > 4 ? 4 : index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing24,
                        vertical: AppConstants.spacing8,
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push('${AppRoutes.transactionDetail}/${transaction.id}');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spacing16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              // Category Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getCategoryIconColor(transaction.category?.color)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                ),
                                child: Icon(
                                  _getCategoryIcon(transaction.category?.icon),
                                  color: _getCategoryIconColor(transaction.category?.color),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing12),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.category?.name ?? 'Transaction',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      transaction.displayDate,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Amount
                              Text(
                                transaction.formattedAmount(user?.currencySymbol ?? 'Rs.'),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: transaction.isExpense ? AppColors.error : AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: transactions.length > 5 ? 5 : transactions.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing64),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color, IconData icon, String currency) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            '$currency ${amount.toStringAsFixed(2)}',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String type) {
    switch (type) {
      case 'ewallet':
        return AppColors.chartBlue;
      case 'bank':
        return AppColors.chartPurple;
      case 'cash':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getMethodIcon(String type) {
    switch (type) {
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getMethodTypeName(String type) {
    switch (type) {
      case 'ewallet':
        return 'E-Wallet';
      case 'bank':
        return 'Bank Account';
      case 'cash':
        return 'Cash';
      default:
        return type;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.chartBlue,
      AppColors.chartCoral,
      AppColors.chartPurple,
      AppColors.chartGreen,
      AppColors.chartYellow,
      AppColors.categoryFood,
      AppColors.categoryShopping,
      AppColors.categoryEntertainment,
    ];
    return colors[index % colors.length];
  }

  Color _getCategoryIconColor(String? colorHex) {
    if (colorHex == null) return AppColors.primary;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String? iconName) {
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