// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const primary = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF1557B0);
  static const primaryLight = Color(0xFFE8F0FE);

  // Status colors
  static const statusNew = Color(0xFF9E9E9E);
  static const statusResponded = Color(0xFF2196F3);
  static const statusInProgress = Color(0xFFFF9800);
  static const statusDone = Color(0xFF4CAF50);

  // Category
  static const categoryFasilitas = Color(0xFF7B1FA2);
  static const categoryIT = Color(0xFF0288D1);

  // Priority
  static const priorityLow = Color(0xFF9E9E9E);
  static const priorityNormal = Color(0xFF2196F3);
  static const priorityHigh = Color(0xFFFF9800);
  static const priorityUrgent = Color(0xFFF44336);

  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

// Widget helper untuk status badge
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'new' => (AppColors.statusNew, 'Baru'),
      'responded' => (AppColors.statusResponded, 'Direspons'),
      'in_progress' => (AppColors.statusInProgress, 'Dikerjakan'),
      'done' => (AppColors.statusDone, 'Selesai'),
      _ => (AppColors.statusNew, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      'low' => (AppColors.priorityLow, 'Rendah'),
      'normal' => (AppColors.priorityNormal, 'Normal'),
      'high' => (AppColors.priorityHigh, 'Tinggi'),
      'urgent' => (AppColors.priorityUrgent, 'Urgent'),
      _ => (AppColors.priorityNormal, priority),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;
  const CategoryBadge(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    final isIT = category == 'it';
    final color = isIT ? AppColors.categoryIT : AppColors.categoryFasilitas;
    final label = isIT ? 'IT' : 'Fasilitas';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
