class FormatUtils {
  FormatUtils._();

  /// Formats a double value as currency in dollars ($)
  static String formatCurrency(double value) {
    return r'$' + value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
