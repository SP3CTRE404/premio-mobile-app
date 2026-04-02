import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/widgets/auth_background.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/subscription_model.dart';
import '../models/subscription_request.dart';
import '../providers/subscription_provider.dart';
import '../widgets/add_subscription/amount_field.dart';
import '../widgets/add_subscription/billing_cycle_field.dart';
import '../widgets/add_subscription/billing_date_field.dart';
import '../widgets/add_subscription/form_label.dart';
import '../widgets/add_subscription/payment_type_field.dart';
import '../widgets/add_subscription/save_subscription_button.dart';
import '../widgets/add_subscription/service_name_field.dart';

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
                    
                    const FormLabel(text: 'Service Name'),
                    ServiceNameField(controller: _nameController),
                    const SizedBox(height: 24),

                    const FormLabel(text: 'Amount'),
                    AmountField(
                      controller: _amountController,
                      currencySymbol: currencySymbol,
                    ),
                    const SizedBox(height: 24),

                    // ─── Billing Cycle Popup ───
                    const FormLabel(text: 'Billing Cycle'),
                    BillingCycleField(
                      selectedCycle: _selectedCycle,
                      onSelected: _onCycleSelected,
                    ),
                    const SizedBox(height: 24),

                    // ─── Payment Type Popup ───
                    const FormLabel(text: 'Payment Type'),
                    PaymentTypeField(
                      isAutoPay: _isAutoPay,
                      onSelected: _onPaymentSelected,
                    ),
                    const SizedBox(height: 24),

                    const FormLabel(text: 'Next Billing Date'),
                    BillingDateField(
                      selectedDate: _selectedDate,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 48),

                    SaveSubscriptionButton(
                      onPressed: _submit,
                      isLoading: _isLoading,
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

  // ─── Logic ───────────────────────────────────────────────────────────────

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