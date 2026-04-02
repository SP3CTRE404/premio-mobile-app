import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/widgets/auth_background.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/subscription_model.dart';
import '../models/subscription_request.dart';
import '../providers/subscription_provider.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BillingCycle? _selectedCycle;
  bool? _isAutoPay;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ─── Compact Popup Pickers ───────────────────────────────────────────────

  void _onCycleSelected(BillingCycle value) => setState(() => _selectedCycle = value);
  void _onPaymentSelected(bool value) => setState(() => _isAutoPay = value);

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    
                    _buildLabel('Service Name'),
                    TextFormField(
                      controller: _nameController,
                      style: theme.textTheme.bodyLarge,
                      decoration: _themedDecoration(theme, 'e.g. Netflix, Gym', Icons.subscriptions_outlined),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Amount'),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: _themedDecoration(theme, '0.00', null).copyWith(
                        prefixIcon: _buildCurrencyPrefix(theme, currencySymbol),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // ─── Billing Cycle Popup ───
                    _buildLabel('Billing Cycle'),
                    _buildPopupMenuField<BillingCycle>(
                      theme: theme,
                      currentValue: _selectedCycle,
                      hint: 'Select Cycle',
                      icon: Icons.autorenew_rounded,
                      displayValue: _getCycleLabel(_selectedCycle),
                      onSelected: _onCycleSelected,
                      items: {
                        BillingCycle.monthly: 'Monthly',
                        BillingCycle.quarterly: 'Every 3 Months',
                        BillingCycle.yearly: 'Yearly',
                      },
                    ),
                    const SizedBox(height: 24),

                    // ─── Payment Type Popup ───
                    _buildLabel('Payment Type'),
                    _buildPopupMenuField<bool>(
                      theme: theme,
                      currentValue: _isAutoPay,
                      hint: 'Select Payment Type',
                      icon: Icons.payment_outlined,
                      displayValue: _getAutoPayLabel(_isAutoPay),
                      onSelected: _onPaymentSelected,
                      items: {
                        true: 'Auto-pay',
                        false: 'Manual',
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Next Billing Date'),
                    _buildPickerField(
                      theme: theme,
                      label: _selectedDate == null ? null : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      hint: 'Tap to select date',
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 48),

                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : const Text('Save Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Optimized Helper Widgets ─────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildCurrencyPrefix(ThemeData theme, String symbol) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            symbol,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // A generic wrapper for fields that trigger a PopupMenu anchored to the field
  Widget _buildPopupMenuField<T>({
    required ThemeData theme,
    required T? currentValue,
    required String hint,
    required IconData icon,
    required String? displayValue,
    required ValueChanged<T> onSelected,
    required Map<T, String> items,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Theme(
          // This local theme removes the shadow, disables tap flash, and styles the popup to match the field
          data: theme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            popupMenuTheme: theme.popupMenuTheme.copyWith(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
            ),
          ),
          child: PopupMenuButton<T>(
            onSelected: onSelected,
            offset: Offset(constraints.maxWidth, 60), // Positions the menu towards the right (where the arrow is)
            tooltip: hint,
            itemBuilder: (context) => items.entries.map((entry) {
              final isSelected = entry.key == currentValue;
              return PopupMenuItem<T>(
                value: entry.key,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 18),
                  ],
                ),
              );
            }).toList(),
            child: IgnorePointer(
              child: TextFormField(
                key: ValueKey(displayValue),
                initialValue: displayValue,
                decoration: _themedDecoration(theme, hint, icon).copyWith(
                  suffixIcon: Icon(Icons.expand_more_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
                validator: (_) => displayValue == null ? 'Required' : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerField({
    required ThemeData theme,
    required String? label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextFormField(
          key: ValueKey(label),
          initialValue: label,
          decoration: _themedDecoration(theme, hint, icon).copyWith(
            suffixIcon: Icon(Icons.expand_more_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ),
          validator: (_) => label == null ? 'Required' : null,
        ),
      ),
    );
  }

  InputDecoration _themedDecoration(ThemeData theme, String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  // ─── Logic ───────────────────────────────────────────────────────────────

  String? _getCycleLabel(BillingCycle? cycle) {
    if (cycle == null) return null;
    return cycle == BillingCycle.monthly ? 'Monthly' : cycle == BillingCycle.quarterly ? 'Every 3 Months' : 'Yearly';
  }

  String? _getAutoPayLabel(bool? isAutoPay) {
    if (isAutoPay == null) return null;
    return isAutoPay ? 'Auto-pay' : 'Manual';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final request = SubscriptionRequest(
        serviceName: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        billingCycle: _selectedCycle!,
        nextBillingDate: _selectedDate!,
        isAutoPay: _isAutoPay!,
      );
      await ref.read(subscriptionProvider.notifier).add(request);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}