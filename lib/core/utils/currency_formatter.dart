/// Format [amount] with the given [symbol] prefix.
///
/// Example: formatCurrency(4250, '₹') → '₹4,250'
String formatCurrency(double amount, String symbol) {
  // Format with commas (Indian / international style)
  final parts = amount.toStringAsFixed(0).split('');
  final buffer = StringBuffer();
  int count = 0;
  for (int i = parts.length - 1; i >= 0; i--) {
    buffer.write(parts[i]);
    count++;
    if (count == 3 && i != 0) {
      buffer.write(',');
      count = 0;
    }
  }
  return '$symbol${buffer.toString().split('').reversed.join()}';
}
