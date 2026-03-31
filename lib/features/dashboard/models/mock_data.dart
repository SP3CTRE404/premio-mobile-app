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
  final String category; // valueScore removed
  final String purchaseDate;
  final String madeBy;

  const MockSub({
    required this.name,
    required this.due,
    required this.price,
    required this.icon,
    required this.statusColor,
    required this.category,
    required this.purchaseDate,
    required this.madeBy,
  });
}

// ──────────────────────────────────────────────
// Mock data for UI development
// ──────────────────────────────────────────────

const mockSubs = [
  // ... your existing 4 subscriptions ...
  MockSub(
    name: 'YouTube Premium',
    due: 'Due in 5 days',
    price: 129,
    icon: Icons.play_circle_fill,
    statusColor: Color(0xFFF57C00),
    category: 'Entertainment',
    purchaseDate: '2024-01-20',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'Microsoft 365',
    due: 'Paid',
    price: 489,
    icon: Icons.description,
    statusColor: AppColors.cobaltBlue,
    category: 'Productivity',
    purchaseDate: '2023-12-15',
    madeBy: 'Jane Doe',
  ),
  MockSub(
    name: 'Disney+',
    due: 'Due in 12 days',
    price: 149,
    icon: Icons.movie_filter,
    statusColor: AppColors.cobaltBlue,
    category: 'Entertainment',
    purchaseDate: '2024-02-10',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'Amazon Prime',
    due: 'Overdue by 3 days',
    price: 1499,
    icon: Icons.shopping_cart,
    statusColor: Color(0xFFD32F2F),
    category: 'Entertainment',
    purchaseDate: '2023-03-25',
    madeBy: 'John Smith',
  ),
  MockSub(
    name: 'ChatGPT Plus',
    due: 'Due in 1 day',
    price: 1650,
    icon: Icons.auto_awesome,
    statusColor: Color(0xFFF57C00),
    category: 'Productivity',
    purchaseDate: '2024-03-05',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'Google One',
    due: 'Paid',
    price: 130,
    icon: Icons.storage,
    statusColor: AppColors.cobaltBlue,
    category: 'Cloud',
    purchaseDate: '2024-02-15',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'PlayStation Plus',
    due: 'Due in 8 days',
    price: 499,
    icon: Icons.games,
    statusColor: AppColors.cobaltBlue,
    category: 'Entertainment',
    purchaseDate: '2024-01-05',
    madeBy: 'Jane Doe',
  ),
  MockSub(
    name: 'Zomato Gold',
    due: 'Paid',
    price: 999,
    icon: Icons.restaurant,
    statusColor: AppColors.cobaltBlue,
    category: 'Finance',
    purchaseDate: '2023-11-20',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'GitHub Copilot',
    due: 'Overdue by 5 days',
    price: 820,
    icon: Icons.code,
    statusColor: Color(0xFFD32F2F),
    category: 'Productivity',
    purchaseDate: '2024-02-22',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'Dropbox',
    due: 'Due in 15 days',
    price: 800,
    icon: Icons.folder_shared,
    statusColor: AppColors.cobaltBlue,
    category: 'Cloud',
    purchaseDate: '2024-03-10',
    madeBy: 'John Smith',
  ),
  MockSub(
    name: 'Coursera Plus',
    due: 'Paid',
    price: 3200,
    icon: Icons.school,
    statusColor: AppColors.cobaltBlue,
    category: 'Productivity',
    purchaseDate: '2024-01-30',
    madeBy: 'Jane Doe',
  ),
  MockSub(
    name: 'Gym Membership',
    due: 'Due in 2 days',
    price: 2500,
    icon: Icons.fitness_center,
    statusColor: Color(0xFFF57C00),
    category: 'Finance',
    purchaseDate: '2024-03-01',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'Skillshare',
    due: 'Paid',
    price: 1200,
    icon: Icons.palette,
    statusColor: AppColors.cobaltBlue,
    category: 'Productivity',
    purchaseDate: '2023-10-12',
    madeBy: 'Me',
  ),
  MockSub(
    name: 'Notion Pro',
    due: 'Due in 4 days',
    price: 660,
    icon: Icons.note_alt,
    statusColor: Color(0xFFF57C00),
    category: 'Productivity',
    purchaseDate: '2024-02-25',
    madeBy: 'Jane Doe',
  ),
  MockSub(
    name: 'NordVPN',
    due: 'Overdue by 10 days',
    price: 450,
    icon: Icons.security,
    statusColor: Color(0xFFD32F2F),
    category: 'Cloud',
    purchaseDate: '2024-01-18',
    madeBy: 'John Smith',
  ),
  MockSub(
    name: 'Twitch Turbo',
    due: 'Due in 6 days',
    price: 730,
    icon: Icons.videocam,
    statusColor: AppColors.cobaltBlue,
    category: 'Entertainment',
    purchaseDate: '2024-03-12',
    madeBy: 'Me',
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