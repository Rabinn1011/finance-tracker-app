import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/main_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final paymentProvider = context.read<PaymentMethodProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    // Use microtask to avoid calling during build
    await Future.microtask(() async {
      await Future.wait([
        paymentProvider.loadPaymentMethods(),
        transactionProvider.loadTransactions(limit: 5),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    final user = authProvider.userProfile;
    final totalBalance = paymentProvider.totalBalance;
    final recentTransactions = transactionProvider.getRecent(5);

    return MainNavigation(
      currentIndex: 0,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Header with user info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    // Name and date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'User',
                            style: AppTextStyles.titleLarge,
                          ),
                          Text(
                            _getFormattedDate(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification icon
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // TODO: Notifications
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL BALANCE',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing8,
                              vertical: AppConstants.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            ),
                            child: Text(
                              '+2%',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        '${user?.currencySymbol ?? 'Rs.'} ${totalBalance.toStringAsFixed(2)}',
                        style: AppTextStyles.balance,
                      ),
                      const SizedBox(height: AppConstants.spacing24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.swap_horiz,
                              label: 'Transfer',
                              onTap: () {
                                // TODO: Transfer
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacing12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Budget',
                              onTap: () {
                                context.push(AppRoutes.budgets);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing24),
            ),

            // Transactions Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRANSACTIONS',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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

            // Transactions List
            if (transactionProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recentTransactions.isEmpty)
              SliverFillRemaining(
                child: Center(
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
                        'No transactions yet',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        'Tap + to add your first transaction',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
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
                    final transaction = recentTransactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing24,
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
                                color: _getCategoryColor(transaction.category?.color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: recentTransactions.length,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing12,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textOnDark, size: 20),
            const SizedBox(width: AppConstants.spacing8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[now.month - 1]} ${now.day}';
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