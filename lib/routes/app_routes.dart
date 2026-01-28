import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'package:package_info_plus/package_info_plus.dart';
import'../screens/add_transaction/add_transaction_screen.dart';
import'../screens/profile/profile_screen.dart';
import'../screens/settings/settings_screen.dart';
import'../screens/analytics/analytics_screen.dart';
import '../screens/payment_methods/payment_methods_screen.dart';
import '../screens/payment_methods/add_payment_method_screen.dart';
import '../screens/transactions/all_transactions_screen.dart';
import '../screens/transactions/transaction_detail_screen.dart';
import '../screens/payment_methods/payment_method_detail_screen.dart';


// import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_page.dart';

/// Route paths
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String analytics = '/analytics';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transaction-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Payment methods
  static const String paymentMethods = '/payment-methods';
  static const String addPaymentMethod = '/add-payment-method';
  static const String paymentMethodDetail = '/payment-method-detail';

  // Budget routes
  static const String budgets = '/budgets';
  static const String createBudget = '/create-budget';
}

/// Router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    routes: [
      // Splash / Onboarding
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app with bottom navigation
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Add transaction (modal/full screen)
      GoRoute(
        path: AppRoutes.addTransaction,
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),

      // Analytics
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // Transactions list
      GoRoute(
        path: AppRoutes.transactions,
        name: 'AllTransactions',
        builder: (context, state) => const AllTransactionsScreen(),
      ),

      // Transaction detail
      GoRoute(
        path: '${AppRoutes.transactionDetail}/:id',
        name: 'transaction-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: id);
        },
      ),

      // Payment methods
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addPaymentMethod,
        name: 'add-payment-method',
        builder: (context, state) => const AddPaymentMethodScreen(),
      ),

      // Payment Methods Details
      GoRoute(
        path: '${AppRoutes.paymentMethodDetail}/:id',  // ← Add :id parameter
        name: 'payment-method-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;  // ← Extract the ID
          return PaymentMethodDetailScreen(paymentMethodId: id);  // ← Correct screen!
        },
      ),

      // Budgets
      GoRoute(
        path: AppRoutes.budgets,
        name: 'budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createBudget,
        name: 'create-budget',
        builder: (context, state) => const CreateBudgetScreen(),
      ),

      // Profile & Settings
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${info.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Finance Tracker',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Get Started'),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Text('Developed by',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16)),
                Text('Rabin',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  _version,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(child: Text('Forgot Password Screen - Coming Soon')),
    );
  }
}

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: const Center(child: Text('Budgets Screen - Coming Soon')),
    );
  }
}

class CreateBudgetScreen extends StatelessWidget {
  const CreateBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Budget')),
      body: const Center(child: Text('Create Budget Screen - Coming Soon')),
    );
  }
}


class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}