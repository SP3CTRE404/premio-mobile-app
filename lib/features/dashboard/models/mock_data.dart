import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ──────────────────────────────────────────────
// Mock subscription model
// ──────────────────────────────────────────────

class MockSub {
  final String name;
  final String due;
  final double price;
  final IconData icon;
  final Color statusColor;
  final double valueScore;
  final String category;

  const MockSub({
    required this.name,
    required this.due,
    required this.price,
    required this.icon,
    required this.statusColor,
    required this.valueScore,
    required this.category,
  });
}

// ──────────────────────────────────────────────
// Mock data for UI development
// ──────────────────────────────────────────────

const mockSubs = [
  MockSub(
    name: 'Adobe Creative Cloud',
    due: 'Overdue by 1 day',
    price: 4230,
    icon: Icons.brush,
    statusColor: Colors.redAccent,
    valueScore: 9.2,
    category: 'Productivity',
  ),
  MockSub(
    name: 'Netflix',
    due: 'Due in 2 days',
    price: 649,
    icon: Icons.movie,
    statusColor: Colors.amberAccent,
    valueScore: 7.5,
    category: 'Entertainment',
  ),
  MockSub(
    name: 'Spotify',
    due: 'Due in 3 days',
    price: 119,
    icon: Icons.music_note,
    statusColor: Colors.amberAccent,
    valueScore: 8.8,
    category: 'Entertainment',
  ),
  MockSub(
    name: 'iCloud+',
    due: 'Paid',
    price: 75,
    icon: Icons.cloud,
    statusColor: AppColors.cobaltBlue,
    valueScore: 6.0,
    category: 'Cloud',
  ),
];

// 6-month mock spending trend
const monthlyTrend = [3200.0, 3800.0, 4100.0, 3950.0, 4250.0, 4250.0];
const monthLabels = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];

// Category definitions
class CategoryDef {
  final String label;
  final IconData icon;
  const CategoryDef(this.label, this.icon);
}

const categories = [
  CategoryDef('All', Icons.grid_view_rounded),
  CategoryDef('Entertainment', Icons.movie_outlined),
  CategoryDef('Productivity', Icons.engineering_outlined),
  CategoryDef('Cloud', Icons.cloud_outlined),
  CategoryDef('Finance', Icons.account_balance_outlined),
];

// Calendar due-date dots (day-of-month → color)
final calendarDots = {
  26: Colors.redAccent,
  28: Colors.amberAccent,
  29: Colors.amberAccent,
};
