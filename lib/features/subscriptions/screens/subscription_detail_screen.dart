import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import './add_subscription_screen.dart';

class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  const SubscriptionDetailScreen({super.key});

  @override
  ConsumerState<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends ConsumerState<SubscriptionDetailScreen> {
  bool _isMenuOpen = false;
  // Placeholder logic: in the future, check if user.householdId is null
  final bool _isSingularUser = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: const Center(
        child: Text('The Vault Content'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── The Revealable Options (Only shown when Menu is toggled open) ──
          if (_isMenuOpen) ...[
            if (_isSingularUser) ...[
              _buildSmallFab(
                icon: Icons.add_home_rounded,
                label: 'Add House',
                onTap: () {
                  setState(() => _isMenuOpen = false);
                  // Trigger household creation logic
                },
              ),
              const SizedBox(height: 12),
            ],
            _buildSmallFab(
              icon: Icons.post_add_rounded,
              label: 'Add Sub',
              onTap: () {
                setState(() => _isMenuOpen = false);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()));
              },
            ),
            const SizedBox(height: 12),
          ],

          // ── The Main Plus Button (Reveals/Hides menu) ──
          FloatingActionButton(
            heroTag: 'main_add_fab',
            onPressed: () {
              if (_isSingularUser) {
                setState(() => _isMenuOpen = !_isMenuOpen);
              } else {
                // If already in a house, skip menu and go directly to Add Sub
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()));
              }
            },
            backgroundColor: AppColors.cobaltBlue,
            shape: const CircleBorder(), // Forces perfect circle
            child: Icon(_isMenuOpen ? Icons.close : Icons.add, size: 30),
          ),

          const SizedBox(height: 16),

          // ── The Search Button (Matches size and shape of the Plus button) ──
          FloatingActionButton(
            heroTag: 'search_vault_fab',
            onPressed: () {
              // Trigger search filter logic
            },
            backgroundColor: AppColors.cobaltBlue,
            shape: const CircleBorder(), // Same shape as Plus
            child: const Icon(Icons.search_rounded, size: 28), // Search icon instead of '5'
          ),
          
          const SizedBox(height: 80), // Keep buttons clear of the bottom navigation bar
        ],
      ),
    );
  }

  /// Helper to build the smaller, labeled action buttons in the reveal menu
  Widget _buildSmallFab({required IconData icon, required String label, required VoidCallback onTap}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: 'small_fab_$label',
          onPressed: onTap,
          backgroundColor: AppColors.cobaltBlue.withOpacity(0.9),
          shape: const CircleBorder(),
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }
}