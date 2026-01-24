import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          children: [
            // Currency Section
            Text(
              'CURRENCY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.monetization_on_outlined),
                    title: const Text('Currency'),
                    subtitle: Text('${user?.currency ?? 'NPR'} (${user?.currencySymbol ?? 'Rs.'})'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showCurrencyDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing24),

            // Display Section
            Text(
              'DISPLAY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Coming soon'),
                    value: false,
                    onChanged: null, // TODO: Implement dark mode
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('Language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language selection - Coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing24),

            // Notifications Section
            Text(
              'NOTIFICATIONS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Get notified about transactions'),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification toggle
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.email_outlined),
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive weekly reports'),
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement email notification toggle
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email notifications - Coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing24),

            // Data & Privacy Section
            Text(
              'DATA & PRIVACY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Export Data'),
                    subtitle: const Text('Download your data as CSV'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export data - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Backup & Restore'),
                    subtitle: const Text('Cloud backup'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup & restore - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      'Delete All Data',
                      style: TextStyle(color: AppColors.error),
                    ),
                    subtitle: const Text('Permanently delete all your data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showDeleteDataDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing24),

            // Security Section
            Text(
              'SECURITY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Biometric Lock'),
                    subtitle: const Text('Use fingerprint or face ID'),
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement biometric lock
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Biometric lock - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change password - Coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacing32),

            // App Version
            Center(
              child: Text(
                'Version ${AppConstants.appVersion}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final currencies = [
      {'code': 'NPR', 'symbol': 'Rs.', 'name': 'Nepali Rupee'},
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text(currency['name']!),
                subtitle: Text('${currency['code']} (${currency['symbol']})'),
                onTap: () async {
                  // Update currency
                  await context.read<AuthProvider>().updateProfile(
                    currency: currency['code'],
                    currencySymbol: currency['symbol'],
                  );
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Currency changed to ${currency['code']}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Delete All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions, payment methods, and categories. This action cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement data deletion
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data deletion - Coming soon'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'Delete All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}