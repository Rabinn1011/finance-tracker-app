/// App-wide constants for spacing, sizing, and other values
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Finance Tracker';
  static const String appVersion = '1.0.0';

  // Spacing System (8-point grid)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // Border Radius (matching the rounded aesthetic from UI)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusRound = 999.0; // Fully rounded

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;

  // Button Heights
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Input Field Heights
  static const double inputHeightSmall = 40.0;
  static const double inputHeightMedium = 48.0;
  static const double inputHeightLarge = 56.0;

  // Card/Container Elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Bottom Navigation Bar
  static const double bottomNavHeight = 70.0;
  static const double bottomNavIconSize = 24.0;

  // Animation Durations (in milliseconds)
  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  // Chart Sizes
  static const double chartHeight = 200.0;
  static const double chartBarWidth = 32.0;
  static const double donutChartSize = 180.0;

  // Transaction Card
  static const double transactionCardHeight = 72.0;
  static const double transactionIconSize = 40.0;

  // Category Button
  static const double categoryButtonSize = 72.0;

  // Default Values
  static const String defaultCurrency = 'NPR';
  static const String defaultCurrencySymbol = 'Rs.';

  // Date Formats
  static const String dateFormatFull = 'MMMM dd, yyyy'; // January 01, 2024
  static const String dateFormatShort = 'MMM dd'; // Jan 01
  static const String dateFormatTime = 'hh:mm a'; // 10:42 AM
  static const String dateFormatDateTime = 'MMM dd, hh:mm a'; // Jan 01, 10:42 AM

  // Transaction Categories (Default)
  static const List<String> defaultCategories = [
    'Food & Dining',
    'Shopping',
    'Travel',
    'Bills',
    'Entertainment',
    'Healthcare',
    'Education',
    'Other',
  ];

  // Payment Method Types
  static const String paymentTypeEwallet = 'ewallet';
  static const String paymentTypeBank = 'bank';
  static const String paymentTypeCash = 'cash';

  // Default Payment Methods (Nepali context)
  static const List<Map<String, String>> defaultPaymentMethods = [
    {'name': 'eSewa', 'type': 'ewallet'},
    {'name': 'Khalti', 'type': 'ewallet'},
    {'name': 'Cash', 'type': 'cash'},
  ];

  // Transaction Types
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeIncome = 'income';

  // Budget Periods
  static const String budgetPeriodWeekly = 'weekly';
  static const String budgetPeriodMonthly = 'monthly';
  static const String budgetPeriodYearly = 'yearly';

  // Analytics Periods
  static const String analyticsPeriodWeek = 'week';
  static const String analyticsPeriodMonth = 'month';
  static const String analyticsPeriodYear = 'year';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxTransactionNoteLength = 200;
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999999.99;

  // Pagination
  static const int transactionsPerPage = 20;
  static const int maxRecentTransactions = 5;

  // Cache Duration (in hours)
  static const int cacheDuration = 24;

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorInvalidInput = 'Invalid input. Please check your data.';
}