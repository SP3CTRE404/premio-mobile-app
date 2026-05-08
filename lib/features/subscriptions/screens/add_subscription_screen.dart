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
import '../../auth/widgets/auth_text_field.dart';
import '../../account/providers/account_provider.dart';
import '../../../shared/widgets/custom_toast.dart';

enum CustomIntervalUnit { days, months, years }


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
  String? _selectedCurrency;
  CustomIntervalUnit _customUnit = CustomIntervalUnit.days;
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
    _selectedDate = widget.initialData?.purchaseDate;
    _selectedCurrency = widget.initialData?.currency;

    // Correctly restore the custom unit if it exists
    if (widget.initialData?.customIntervalUnit != null) {
      _customUnit = CustomIntervalUnit.values.firstWhere(
        (e) => e.name.toUpperCase() == widget.initialData!.customIntervalUnit!.toUpperCase(),
        orElse: () => CustomIntervalUnit.days,
      );
    }
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

  void _showCurrencyPicker(String currentSymbol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choose Currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: Consumer(
                  builder: (context, ref, child) {
                    final asyncData = ref.watch(availableCurrenciesProvider);
                    return asyncData.when(
                      data: (currencies) => ListView.builder(
                        shrinkWrap: true,
                        itemCount: currencies.length,
                        itemBuilder: (_, index) {
                          final currency = currencies[index];
                          final isSelected = currency.symbol == currentSymbol;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? const Color(0xFF0033FF) // cobalt blue
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                              child: Text(
                                currency.symbol,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(currency.name),
                            subtitle: Text(currency.code),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Color(0xFF0033FF))
                                : null,
                            onTap: () {
                              setState(() => _selectedCurrency = currency.symbol);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(child: Text('Error: $err')),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(nativeCurrencyProvider);

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
                      currencySymbol: _selectedCurrency ?? currencySymbol,
                      onCurrencyTap: () => _showCurrencyPicker(_selectedCurrency ?? currencySymbol),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AuthTextField(
                              label: 'Interval Value',
                              hint: 'e.g. 14',
                              controller: _customDaysController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Unit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 56, // Match AuthTextField TextFormField height
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.transparent, // Match AuthTextField style
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<CustomIntervalUnit>(
                                      value: _customUnit,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      items: CustomIntervalUnit.values.map((unit) {
                                        return DropdownMenuItem(
                                          value: unit,
                                          child: Text(
                                            unit.name[0].toUpperCase() + unit.name.substring(1),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _customUnit = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    if (_selectedCycle != BillingCycle.oneTime) ...[
                      const FormLabel(text: 'Payment Method'),
                      PaymentTypeField(
                        isAutoPay: _isAutoPay,
                        onSelected: _onPaymentSelected,
                      ),
                      const SizedBox(height: 24),
                    ],

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
    if (_selectedCycle != BillingCycle.oneTime && _isAutoPay == null) {
      CustomToast.show(context: context, message: 'Please select a payment type', isError: true);
      return;
    }
    if (_selectedDate == null) {
      CustomToast.show(context: context, message: 'Please select a billing date', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {

      final request = SubscriptionRequest(
        serviceName: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        billingCycle: _selectedCycle!,
        customIntervalDays: _selectedCycle == BillingCycle.custom 
            ? int.tryParse(_customDaysController.text.trim()) 
            : null,
        customIntervalUnit: _selectedCycle == BillingCycle.custom 
            ? _customUnit.name.toUpperCase() 
            : null,
        nextBillingDate: null, // Backend will calculate this
        purchaseDate: _selectedDate!,
        isAutoPay: _selectedCycle == BillingCycle.oneTime ? false : (_isAutoPay ?? true),
        userId: widget.targetUserId ?? ref.read(userProvider).value?.id,
        currency: _selectedCurrency ?? ref.read(nativeCurrencyProvider), // Save the native currency as default
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
