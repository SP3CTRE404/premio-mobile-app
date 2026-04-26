import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';

/// Notifier that holds the user's chosen currency symbol.
/// Persists the value via [SecureStorageService] so it survives restarts.
class CurrencySymbolNotifier extends Notifier<String> {
  @override
  String build() {
    _loadFromStorage();
    return '₹'; // default until async load completes
  }

  Future<void> _loadFromStorage() async {
    final storage = ref.read(secureStorageServiceProvider);
    final saved = await storage.getCurrency();
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> set(String symbol) async {
    state = symbol;
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveCurrency(symbol);
  }
}

/// The user's chosen currency symbol (e.g. '₹', '$', '€', '£', '¥').
/// Defaults to '₹' but can be changed from Settings.
final currencySymbolProvider =
    NotifierProvider<CurrencySymbolNotifier, String>(
  CurrencySymbolNotifier.new,
);

/// Common currency options for the settings picker.
class CurrencyOption {
  final String symbol;
  final String code;
  final String name;

  const CurrencyOption({
    required this.symbol,
    required this.code,
    required this.name,
  });
}

const availableCurrencies = [
  CurrencyOption(symbol: '₹', code: 'INR', name: 'Indian Rupee'),
  CurrencyOption(symbol: '\$', code: 'USD', name: 'US Dollar'),
  CurrencyOption(symbol: '€', code: 'EUR', name: 'Euro'),
  CurrencyOption(symbol: '£', code: 'GBP', name: 'British Pound'),
  CurrencyOption(symbol: '¥', code: 'JPY', name: 'Japanese Yen'),
  CurrencyOption(symbol: '₩', code: 'KRW', name: 'South Korean Won'),
  CurrencyOption(symbol: 'A\$', code: 'AUD', name: 'Australian Dollar'),
  CurrencyOption(symbol: 'C\$', code: 'CAD', name: 'Canadian Dollar'),
  CurrencyOption(symbol: '₿', code: 'BTC', name: 'Bitcoin'),
];
