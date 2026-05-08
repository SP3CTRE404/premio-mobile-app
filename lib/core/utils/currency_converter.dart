class CurrencyConverter {
  // Hardcoded approximate exchange rates relative to USD (Base: USD = 1.0)
  // In a real app, these would be fetched from a live API and cached.
  static const Map<String, double> _ratesToUSD = {
    'USD': 1.0,
    'INR': 83.5,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 155.0,
    'KRW': 1365.0,
    'AUD': 1.52,
    'CAD': 1.36,
    'BTC': 0.000016, // Approx 1 USD = 0.000016 BTC
  };

  /// Converts an amount from one currency to another.
  /// Currency inputs should be the **Currency Code** (e.g. 'USD', 'INR') OR **Currency Symbol** (e.g. '\$', '₹').
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    final fromCode = _getCodeFromSymbolOrCode(fromCurrency);
    final toCode = _getCodeFromSymbolOrCode(toCurrency);

    final fromRate = _ratesToUSD[fromCode] ?? 1.0;
    final toRate = _ratesToUSD[toCode] ?? 1.0;

    // Convert to USD first, then to target currency
    final amountInUSD = amount / fromRate;
    return amountInUSD * toRate;
  }

  static String _getCodeFromSymbolOrCode(String input) {
    // If it's already a 3-letter code, return it upper cased
    if (input.length == 3 && RegExp(r'^[A-Za-z]{3}$').hasMatch(input)) {
      return input.toUpperCase();
    }

    // Map common symbols to codes based on availableCurrencies in currency_provider.dart
    switch (input) {
      case '₹': return 'INR';
      case '\$': return 'USD';
      case '€': return 'EUR';
      case '£': return 'GBP';
      case '¥': return 'JPY';
      case '₩': return 'KRW';
      case 'A\$': return 'AUD';
      case 'C\$': return 'CAD';
      case '₿': return 'BTC';
      default: return 'USD'; // Fallback
    }
  }
}
