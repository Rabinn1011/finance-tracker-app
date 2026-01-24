import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/main_navigation.dart';
import 'dart:math' as math;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'month'; // 'week', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();

    switch (_selectedPeriod) {
      case 'week':
        await transactionProvider.loadWeeklyTransactions();
        break;
      case 'month':
        await transactionProvider.loadMonthlyTransactions();
        break;
      case 'year':
        await transactionProvider.loadYearlyTransactions();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    final totalExpenses = transactionProvider.totalExpenses;
    final totalIncome = transactionProvider.totalIncome;
    final balance = totalIncome - totalExpenses;

    // Calculate category breakdown
    final expenses = transactionProvider.expenses;
    final categoryTotals = <String, double>{};
    for (var transaction in expenses) {
      final categoryName = transaction.category?.name ?? 'Other';
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + transaction.amount;
    }

    // Sort by amount
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return MainNavigation(
      currentIndex: 1,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics',
                      style: AppTextStyles.displaySmall,
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Track your spending patterns',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Period Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Row(
                  children: [
                    Expanded(child: _buildPeriodButton('Week', 'week')),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(child: _buildPeriodButton('Month', 'month')),
                    const SizedBox(width: AppConstants.spacing8),
                    Expanded(child: _buildPeriodButton('Year', 'year')),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing24),
            ),

            // Summary Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Income',
                        totalIncome,
                        AppColors.success,
                        Icons.arrow_downward,
                        user?.currencySymbol ?? 'Rs.',
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Expenses',
                        totalExpenses,
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
              child: SizedBox(height: AppConstants.spacing12),
            ),

            // Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing20),
                  decoration: BoxDecoration(
                    color: balance >= 0 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: balance >= 0 ? AppColors.success : AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Balance',
                        style: AppTextStyles.titleMedium,
                      ),
                      Text(
                        '${balance >= 0 ? '+' : ''}${user?.currencySymbol ?? 'Rs.'} ${balance.toStringAsFixed(2)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: balance >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing32),
            ),

            // Spending by Category Header
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
            if (transactionProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (sortedCategories.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'No transactions for this period',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = sortedCategories[index];
                    final percentage = totalExpenses > 0 ? (category.value / totalExpenses * 100) : 0;
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
              child: SizedBox(height: AppConstants.spacing64),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
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
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
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
}