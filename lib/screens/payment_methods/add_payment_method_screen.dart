import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/payment_method_provider.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');

  String _selectedType = 'ewallet'; // 'ewallet', 'bank', 'cash'
  String _selectedIcon = 'default';

  final Map<String, List<Map<String, String>>> _presetMethods = {
    'ewallet': [
      {'name': 'eSewa', 'icon': 'esewa'},
      {'name': 'Khalti', 'icon': 'khalti'},
      {'name': 'IME Pay', 'icon': 'imepay'},
      {'name': 'Prabhupay', 'icon': 'prabhupay'},
      {'name': 'Custom E-Wallet', 'icon': 'default'},
    ],
    'bank': [
      {'name': 'NMB Bank', 'icon': 'nmb'},
      {'name': 'Global IME Bank', 'icon': 'globalime'},
      {'name': 'Nabil Bank', 'icon': 'nabil'},
      {'name': 'Everest Bank', 'icon': 'everest'},
      {'name': 'Custom Bank', 'icon': 'default'},
    ],
    'cash': [
      {'name': 'Cash', 'icon': 'cash'},
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    if (balance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Balance cannot be negative'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final paymentProvider = context.read<PaymentMethodProvider>();

    final success = await paymentProvider.createPaymentMethod(
      name: name,
      type: _selectedType,
      icon: _selectedIcon,
      balance: balance,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.errorMessage ?? 'Failed to add payment method'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final presets = _presetMethods[_selectedType] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Selection
                Text(
                  'TYPE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeCard(
                        'E-Wallet',
                        'ewallet',
                        Icons.account_balance_wallet,
                        AppColors.chartBlue,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _buildTypeCard(
                        'Bank',
                        'bank',
                        Icons.account_balance,
                        AppColors.chartPurple,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: _buildTypeCard(
                        'Cash',
                        'cash',
                        Icons.money,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Preset Selection
                Text(
                  'SELECT OR CREATE CUSTOM',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),

                // Preset Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _nameController.text = preset['name']!;
                          _selectedIcon = preset['icon']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing16,
                          vertical: AppConstants.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: _nameController.text == preset['name']
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          border: Border.all(
                            color: _nameController.text == preset['name']
                                ? AppColors.primary
                                : AppColors.border,
                            width: _nameController.text == preset['name'] ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          preset['name']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _nameController.text == preset['name']
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: _nameController.text == preset['name']
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppConstants.spacing24),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter payment method name',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.spacing16),

                // Initial Balance Field
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                    helperText: 'Enter current balance in this account',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter initial balance';
                    }
                    final balance = double.tryParse(value);
                    if (balance == null) {
                      return 'Please enter a valid number';
                    }
                    if (balance < 0) {
                      return 'Balance cannot be negative';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.spacing32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: Text(
                          'The initial balance will be set to this amount. You can add income or expense transactions later to update it.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacing32),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: paymentProvider.isLoading ? null : _savePaymentMethod,
                    child: paymentProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnDark,
                        ),
                      ),
                    )
                        : const Text('Add Payment Method'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(String label, String type, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _nameController.clear();
          _selectedIcon = 'default';
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}