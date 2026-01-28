import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/main_navigation.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<PaymentMethodProvider>().loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;
    final paymentMethods = paymentProvider.paymentMethods;

    return MainNavigation(
      currentIndex: 3,
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
                      'Payment Methods',
                      style: AppTextStyles.displaySmall,
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Manage your wallets and accounts',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Total Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accentLight],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL BALANCE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        '${user?.currencySymbol ?? 'Rs.'} ${paymentProvider.totalBalance.toStringAsFixed(2)}',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        'Across ${paymentMethods.length} payment methods',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing24),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR PAYMENT METHODS',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.addPaymentMethod);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacing12),
            ),

            // Payment Methods List
            if (paymentProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (paymentMethods.isEmpty)
              SliverFillRemaining(
                child: Center(
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
                        'No payment methods yet',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.addPaymentMethod);
                        },
                        child: const Text('Add your first payment method'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final method = paymentMethods[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing24,
                        vertical: AppConstants.spacing8,
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push('/payment-method-detail/${method.id}');
                        },
                        child: Container(
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
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _getMethodColor(method.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                ),
                                child: Icon(
                                  _getMethodIcon(method.type),
                                  color: _getMethodColor(method.type),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing16),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.name,
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getMethodTypeName(method.type),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Balance
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${user?.currencySymbol ?? 'Rs.'} ${method.safeBalance.toStringAsFixed(2)}',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: method.safeIsActive
                                          ? AppColors.success.withOpacity(0.1)
                                          : AppColors.textTertiary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                    ),
                                    child: Text(
                                      method.safeIsActive ? 'Active' : 'Inactive',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: method.safeIsActive ? AppColors.success : AppColors.textTertiary,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: paymentMethods.length,
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
}