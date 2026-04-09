import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/widgets/auth_background.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/subscription_model.dart';
import '../models/subscription_request.dart';
import '../providers/subscription_provider.dart';
import '../utils/subscription_date_helper.dart';
import '../widgets/add_subscription/amount_field.dart';

import '../widgets/add_subscription/billing_cycle_field.dart';
import '../widgets/add_subscription/billing_date_field.dart';
import '../widgets/add_subscription/form_label.dart';
import '../widgets/add_subscription/payment_type_field.dart';
import '../widgets/add_subscription/save_subscription_button.dart';
import '../widgets/add_subscription/service_name_field.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../account/providers/account_provider.dart';
import '../../../core/widgets/custom_toast.dart';


class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? initialData;
  final int? targetUserId;

  const AddSubscriptionScreen({super.key, this.initialData, this.targetUserId});


  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _customDaysController;

  BillingCycle? _selectedCycle;
  bool? _isAutoPay;
  DateTime? _selectedDate;
  bool _isLoading = false;
  // bool _isShared = false;



  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?.serviceName);
    _amountController = TextEditingController(text: widget.initialData?.amount.toString());
    _customDaysController = TextEditingController(
      text: widget.initialData?.customIntervalDays?.toString() ?? ''
    );
    
    _isAutoPay = widget.initialData?.isAutoPay;
    _selectedCycle = widget.initialData?.billingCycle;
    // _isShared = widget.initialData?.householdId != null || widget.targetHouseholdId != null;
  }



  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _customDaysController.dispose();
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
      firstDate: DateTime(2000), // Allow historical purchases
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),

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
        title: Text(
          widget.initialData != null ? 'Edit Subscription' : 'New Subscription',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                    if (_selectedCycle == BillingCycle.custom) ...[
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Custom Interval (Days)',
                        hint: 'e.g. 14',
                        controller: _customDaysController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // ─── Payment Type Popup ───
                    const FormLabel(text: 'Payment Method'),
                    PaymentTypeField(
                      isAutoPay: _isAutoPay,
                      onSelected: _onPaymentSelected,
                    ),
                    const SizedBox(height: 24),

                    const FormLabel(text: 'Date of Purchase'),

                    BillingDateField(
                      selectedDate: _selectedDate,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 48),




                    SaveSubscriptionButton(
                      text: widget.initialData != null ? 'Save Changes' : null,
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
    if (_selectedCycle == null) {
      CustomToast.show(context: context, message: 'Please select a billing cycle', isError: true);
      return;
    }
    if (_isAutoPay == null) {
      CustomToast.show(context: context, message: 'Please select a payment type', isError: true);
      return;
    }
    if (_selectedDate == null) {
      CustomToast.show(context: context, message: 'Please select a billing date', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final calculatedNextBilling = SubscriptionDateHelper.calculateNextBillingDate(
        _selectedDate!, 
        _selectedCycle!,
        customDays: _selectedCycle == BillingCycle.custom 
            ? int.tryParse(_customDaysController.text.trim()) 
            : null,
      );

      final request = SubscriptionRequest(
        serviceName: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        billingCycle: _selectedCycle!,
        customIntervalDays: _selectedCycle == BillingCycle.custom 
            ? int.tryParse(_customDaysController.text.trim()) 
            : null,
        nextBillingDate: calculatedNextBilling,
        isAutoPay: _isAutoPay!,
        userId: widget.targetUserId ?? ref.read(userProvider).value?.id,
      );




      if (widget.initialData != null) {
        await ref.read(subscriptionProvider.notifier).updateSubscription(widget.initialData!.id, request);
      } else {
        await ref.read(subscriptionProvider.notifier).add(request);
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) CustomToast.show(context: context, message: 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
