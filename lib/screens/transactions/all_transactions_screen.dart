import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../models/transaction_model.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _filterType = 'all'; // 'all', 'expense', 'income'
  String? _filterCategory;
  String? _filterPaymentMethod;
  final _searchController = TextEditingController();
  bool _showFilters = false;

  // Pagination variables
  int _currentLimit = 10;
  final int _incrementLimit = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final paymentProvider = context.read<PaymentMethodProvider>();

    await Future.wait([
      transactionProvider.loadTransactions(
        type: _filterType == 'all' ? null : _filterType,
        categoryId: _filterCategory,
        paymentMethodId: _filterPaymentMethod,
        limit: _currentLimit,
      ),
      categoryProvider.loadCategories(),
      paymentProvider.loadPaymentMethods(),
    ]);
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentLimit += _incrementLimit;
    });

    final transactionProvider = context.read<TransactionProvider>();
    await transactionProvider.loadTransactions(
      type: _filterType == 'all' ? null : _filterType,
      categoryId: _filterCategory,
      paymentMethodId: _filterPaymentMethod,
      limit: _currentLimit,
    );

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _showFilters = false;
      _currentLimit = 10; // Reset to initial limit when filters change
    });
    _loadData();
  }

  void _clearFilters() {
    setState(() {
      _filterType = 'all';
      _filterCategory = null;
      _filterPaymentMethod = null;
      _searchController.clear();
      _currentLimit = 10; // Reset to initial limit
    });
    _loadData();
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    if (_searchController.text.isEmpty) return transactions;

    final query = _searchController.text.toLowerCase();
    return transactions.where((t) {
      final categoryName = t.category?.name.toLowerCase() ?? '';
      final paymentName = t.paymentMethod?.name.toLowerCase() ?? '';
      final notes = t.notes?.toLowerCase() ?? '';
      return categoryName.contains(query) ||
          paymentName.contains(query) ||
          notes.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    final allTransactions = transactionProvider.transactions;
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    // Check if there might be more transactions to load
    final hasMore = allTransactions.length >= _currentLimit;

    // Group by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (var transaction in filteredTransactions) {
      final dateKey = _formatDateKey(transaction.transactionDate);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Transactions'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // Filters Panel
            if (_showFilters)
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FILTERS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    // Type Filter
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterChip('All', 'all'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterChip('Expense', 'expense'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterChip('Income', 'income'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacing12),

                    // Category Filter
                    DropdownButtonFormField<String>(
                      value: _filterCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categoryProvider.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: AppConstants.spacing12),

                    // Payment Method Filter
                    DropdownButtonFormField<String>(
                      value: _filterPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing12,
                          vertical: AppConstants.spacing8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Payment Methods'),
                        ),
                        ...paymentProvider.paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method.id,
                            child: Text(method.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterPaymentMethod = value;
                        });
                      },
                    ),

                    const SizedBox(height: AppConstants.spacing16),

                    // Apply/Clear Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const Divider(height: 1),

            // Transactions List
            Expanded(
              child: transactionProvider.isLoading && _currentLimit == 10
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTransactions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      'No transactions found',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _currentLimit = 10;
                  });
                  await _loadData();
                },
                child: ListView.builder(
                  itemCount: groupedTransactions.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show "Load More" button at the end
                    if (index == groupedTransactions.length) {
                      return Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing24),
                        child: Center(
                          child: _isLoadingMore
                              ? const CircularProgressIndicator()
                              : OutlinedButton.icon(
                            onPressed: _loadMoreTransactions,
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Load More'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final dateKey = groupedTransactions.keys.elementAt(index);
                    final transactions = groupedTransactions[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.spacing16),
                          child: Text(
                            dateKey,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Transactions for this date
                        ...transactions.map((transaction) {
                          return InkWell(
                            onTap: () {
                              context.push('${AppRoutes.transactionDetail}/${transaction.id}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing16,
                                vertical: AppConstants.spacing8,
                              ),
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
                                        color: _getCategoryColor(transaction.category?.color)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.radiusMedium),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(transaction.category?.icon),
                                        color: _getCategoryColor(transaction.category?.color),
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.spacing12),
                                    // Transaction details
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
                                            transaction.paymentMethod?.name ?? 'Unknown',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Amount
                                    Text(
                                      transaction.formattedAmount(
                                          user?.currencySymbol ?? 'Rs.'),
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: transaction.isExpense
                                            ? AppColors.error
                                            : AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  Color _getCategoryColor(String? colorHex) {
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