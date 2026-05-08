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

class CountryService {
  static const String _baseUrl = 'https://restcountries.com/v3.1/all?fields=name,currencies';

  Future<List<CurrencyOption>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<CurrencyOption> options = [];
        
        for (var item in data) {
          final map = item as Map<String, dynamic>;
          final name = map['name']?['common'] as String?;
          final currencies = map['currencies'] as Map<String, dynamic>?;
          
          if (name != null && currencies != null && currencies.isNotEmpty) {
            final currencyCode = currencies.keys.first;
            final currencyDetails = currencies[currencyCode] as Map<String, dynamic>;
            
            options.add(CurrencyOption(
              code: currencyCode,
              name: name,
              symbol: currencyDetails['symbol'] ?? currencyCode,
            ));
          }
        }
        
        options.sort((a, b) => a.name.compareTo(b.name));
        return options;
      }
      throw Exception('Failed to load countries');
    } catch (e) {
      return [
        const CurrencyOption(symbol: '₹', code: 'INR', name: 'India'),
        const CurrencyOption(symbol: r'$', code: 'USD', name: 'United States'),
        const CurrencyOption(symbol: '€', code: 'EUR', name: 'European Union'),
        const CurrencyOption(symbol: '£', code: 'GBP', name: 'United Kingdom'),
      ];
    }
  }
}

final availableCurrenciesProvider = FutureProvider<List<CurrencyOption>>((ref) async {
  final service = CountryService();
  return await service.fetchCountries();
});
