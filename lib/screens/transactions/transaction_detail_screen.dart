import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/transaction_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Transaction? _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoading = true);

    final transactionProvider = context.read<TransactionProvider>();
    final transaction = transactionProvider.getById(widget.transactionId);

    setState(() {
      _transaction = transaction;
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final transactionProvider = context.read<TransactionProvider>();
      final success = await transactionProvider.deleteTransaction(widget.transactionId);

      if (success && mounted) {
        // Reload payment methods to update balance
        await context.read<PaymentMethodProvider>().loadPaymentMethods();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(); // Go back
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transactionProvider.errorMessage ?? 'Failed to delete transaction'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transaction Details'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_transaction == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transaction Details'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
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
                'Transaction not found',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final transaction = _transaction!;
    final isExpense = transaction.isExpense;
    final color = isExpense ? AppColors.error : AppColors.success;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteTransaction,
            color: AppColors.error,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Amount Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacing32),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing12,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        isExpense ? 'EXPENSE' : 'INCOME',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      transaction.formattedAmount(user?.currencySymbol ?? 'Rs.'),
                      style: AppTextStyles.displayLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacing24),

              // Details Section
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETAILS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // Category
                    _buildDetailCard(
                      icon: _getCategoryIcon(transaction.category?.icon),
                      iconColor: _getCategoryColor(transaction.category?.color),
                      title: 'Category',
                      value: transaction.category?.name ?? 'Unknown',
                    ),

                    const SizedBox(height: AppConstants.spacing12),

                    // Payment Method
                    _buildDetailCard(
                      icon: _getPaymentIcon(transaction.paymentMethod?.type),
                      iconColor: AppColors.chartBlue,
                      title: 'Payment Method',
                      value: transaction.paymentMethod?.name ?? 'Unknown',
                    ),

                    const SizedBox(height: AppConstants.spacing12),

                    // Date
                    _buildDetailCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.chartPurple,
                      title: 'Date',
                      value: _formatDate(transaction.transactionDate),
                    ),

                    const SizedBox(height: AppConstants.spacing12),

                    // Time
                    _buildDetailCard(
                      icon: Icons.access_time,
                      iconColor: AppColors.chartGreen,
                      title: 'Created',
                      value: _formatDateTime(transaction.createdAt),
                    ),

                    if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacing24),
                      Text(
                        'NOTES',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          transaction.notes!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacing32),

                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showEditDialog(context, transaction);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: const Text('Edit Transaction'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  IconData _getPaymentIcon(String? type) {
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final date = _formatDate(dateTime);
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$date at $hour:$minute $period';
  }

  void _showEditDialog(BuildContext context, Transaction transaction) {
    final notesController = TextEditingController(text: transaction.notes);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Add a note...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final transactionProvider = context.read<TransactionProvider>();

              final success = await transactionProvider.updateTransaction(
                id: transaction.id,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              if (success && context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadTransaction(); // Reload to show changes
              } else if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(transactionProvider.errorMessage ?? 'Failed to update'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}