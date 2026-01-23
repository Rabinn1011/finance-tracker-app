import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/main_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    return MainNavigation(
      currentIndex: 4,
      child: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Name
                  Text(
                    user?.fullName ?? 'User',
                    style: AppTextStyles.headlineMedium,
                  ),

                  const SizedBox(height: AppConstants.spacing8),

                  // Currency
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      '${user?.currency ?? 'NPR'} (${user?.currencySymbol ?? 'Rs.'})',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing24),
          ),

          // Account Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              child: Text(
                'ACCOUNT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing12),
          ),

          // Account Options
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payment Methods',
                    onTap: () {
                      context.push(AppRoutes.paymentMethods);
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Categories',
                    onTap: () {
                      // TODO: Categories screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Categories screen - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: 'Budgets',
                    onTap: () {
                      context.push(AppRoutes.budgets);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing24),
          ),

          // Settings Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              child: Text(
                'SETTINGS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing12),
          ),

          // Settings Options
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Edit profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Notifications screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      // TODO: Change password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change password - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Preferences',
                    onTap: () {
                      context.push(AppRoutes.settings);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing24),
          ),

          // About Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              child: Text(
                'ABOUT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing12),
          ),

          // About Options
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'About App',
                    trailing: Text(
                      AppConstants.appVersion,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // TODO: Privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy Policy - Coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {
                      // TODO: Terms of service
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms of Service - Coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing32),
          ),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      'Logout',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing64),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        Widget? trailing,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing4,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear all provider data
              context.read<PaymentMethodProvider>().clear();
              context.read<CategoryProvider>().clear();
              context.read<TransactionProvider>().clear();

              // Logout
              await context.read<AuthProvider>().signOut();

              if (context.mounted) {
                context.pop(); // Close dialog
                context.go(AppRoutes.login); // Go to login
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: AppConstants.spacing12),
            const Text('Finance Tracker'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppConstants.appVersion}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'A simple and elegant finance tracking app to help you manage your income and expenses.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Developed by Rabin',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}