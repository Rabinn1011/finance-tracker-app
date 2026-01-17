import 'package:flutter/material.dart';

/// App color palette based on the design mockup
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF2C2C2C); // Dark charcoal
  static const Color background = Color(0xFFF5F3EF); // Cream/Beige
  static const Color surface = Color(0xFFFFFFFF); // White for cards

  // Accent Colors
  static const Color accent = Color(0xFF2C2C2C); // Same as primary for buttons
  static const Color accentLight = Color(0xFF4A4A4A); // Lighter variant

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green for income/positive
  static const Color error = Color(0xFFFF6B6B); // Coral/Red for expense/negative
  static const Color warning = Color(0xFFFFA726); // Orange for warnings
  static const Color info = Color(0xFF5B9BD5); // Blue for info

  // Chart Colors
  static const Color chartBlue = Color(0xFF5B9BD5);
  static const Color chartCoral = Color(0xFFFF6B6B);
  static const Color chartPurple = Color(0xFF9B59B6);
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartYellow = Color(0xFFFFC107);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C); // Dark for main text
  static const Color textSecondary = Color(0xFF757575); // Gray for secondary text
  static const Color textTertiary = Color(0xFFBDBDBD); // Light gray for hints
  static const Color textOnDark = Color(0xFFFFFFFF); // White text on dark background

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Background Variants
  static const Color backgroundLight = Color(0xFFFAF9F7); // Slightly lighter
  static const Color backgroundDark = Color(0xFFEBE9E5); // Slightly darker

  // Category Colors (for transaction categories)
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTravel = Color(0xFF5B9BD5);
  static const Color categoryBills = Color(0xFFFFA726);
  static const Color categoryOther = Color(0xFF9E9E9E);
  static const Color categoryShopping = Color(0xFF9B59B6);
  static const Color categoryEntertainment = Color(0xFFE91E63);

  // Payment Method Colors
  static const Color esewa = Color(0xFF60BB46); // eSewa green
  static const Color khalti = Color(0xFF5C2D91); // Khalti purple
  static const Color bank = Color(0xFF1976D2); // Generic bank blue
  static const Color cash = Color(0xFF4CAF50); // Cash green

  // Shadow
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color shadowLight = Color(0x0D000000); // 5% black
}