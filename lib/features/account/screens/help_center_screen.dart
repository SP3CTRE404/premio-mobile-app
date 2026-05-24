import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _faqs = [
    {
      'category': 'General',
      'question': 'What is Premio?',
      'answer': 'Premio is a subscription tracking and management tool. It lets you monitor your subscriptions, keep track of recurring billing cycles, coordinate household budgets, and receive manual-pay reminders.',
    },
    {
      'category': 'Billing & Reminders',
      'question': 'How do notifications work in Premio?',
      'answer': 'Premio checks for upcoming or overdue manual-pay subscriptions daily (scheduled around 7:59 AM) and triggers push notifications. Auto-pay subscriptions trigger a renewal reminder 1 day prior, and a renewal alert on the day of renewal. Make sure you enable notifications in your phone settings to receive these alerts.',
    },
    {
      'category': 'Household Sharing',
      'question': 'How do I invite members to my household?',
      'answer': 'Go to the Household section, tap on the "Invite" icon to generate a unique invite link or QR code. Your household members can scan this QR code or input the 8-digit invite code in the "Join Household" screen to connect.',
    },
    {
      'category': 'Household Sharing',
      'question': 'What is the difference between Admin and Member roles?',
      'answer': 'Admins have full visibility and control. They can add, edit, or delete subscriptions for the entire household, invite new members, and transfer administration. Members can only view the shared subscriptions and track their own personal subscription list.',
    },
    {
      'category': 'Security',
      'question': 'How does App Lock protect my financial data?',
      'answer': 'By enabling App Lock in Settings > Security, Premio will request Face ID, Fingerprint, or a custom secure PIN every time you open or resume the app. This safeguards your subscriptions and household details from local unauthorized access.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter FAQs based on query
    final filteredFaqs = _faqs.where((faq) {
      final matchesQuery = faq['question']!.toLowerCase().contains(_searchQuery) ||
          faq['answer']!.toLowerCase().contains(_searchQuery);
      return matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Premium Search Bar Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: theme.scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search FAQ, help topics...',
                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardTheme.color ?? colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.cobaltBlue, width: 1.5),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No FAQ found',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different terms.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Theme(
                          data: theme.copyWith(dividerColor: Colors.transparent),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color ?? colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.01),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ExpansionTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.help_center_outlined, color: AppColors.cobaltBlue, size: 20),
                                ),
                                title: Text(
                                  faq['question']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                iconColor: AppColors.cobaltBlue,
                                collapsedIconColor: colorScheme.onSurface.withValues(alpha: 0.4),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      faq['answer']!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.5,
                                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
