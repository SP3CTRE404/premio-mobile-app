import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import '../../account/providers/account_provider.dart';

/// Notifier that holds the user's chosen DISPLAY currency preference for the dashboard.
/// This only affects estimates and is persisted locally via [SecureStorageService].
class DisplayCurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    // Initialize from local storage, fallback to user's native currency
    final user = ref.watch(userProvider).value;
    final nativeSymbol = user?.currencySymbol ?? '₹';
    
    _loadFromStorage();
    return nativeSymbol;
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
    
    // Save to local storage for offline use
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveCurrency(symbol);

    // Note: We no longer sync this with the backend profile updateProfile 
    // because the user wants this to be a local display preference only.
  }
}

/// The global display currency preference (affects dashboard totals).
final displayCurrencyProvider =
    NotifierProvider<DisplayCurrencyNotifier, String>(
  DisplayCurrencyNotifier.new,
);

/// The user's native registration currency (immutable fallback for subscriptions).
final nativeCurrencyProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.currencySymbol ?? '₹';
});

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

class FrankfurterService {
  static const String _baseUrl = 'https://api.frankfurter.dev/v2';

  // Helper map to assign symbols to common codes
  static const Map<String, String> _currencySymbols = {
    'INR': '₹', 'USD': r'$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 
    'KRW': '₩', 'AUD': r'A$', 'CAD': r'C$', 'CHF': 'CHF', 'CNY': '¥',
  };

  Future<List<CurrencyOption>> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/currencies'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        return data.entries.map((entry) {
          return CurrencyOption(
            code: entry.key,
            name: entry.value.toString(),
            symbol: _currencySymbols[entry.key] ?? entry.key, // Fallback to code
          );
        }).toList();
      }
      throw Exception('Failed to load currencies');
    } catch (e) {
      // Fallback list for offline or error states
      return [
        const CurrencyOption(symbol: '₹', code: 'INR', name: 'Indian Rupee'),
        const CurrencyOption(symbol: r'$', code: 'USD', name: 'US Dollar'),
      ];
    }
  }
}

final availableCurrenciesProvider = FutureProvider<List<CurrencyOption>>((ref) async {
  final service = FrankfurterService();
  return await service.fetchCurrencies();
});
