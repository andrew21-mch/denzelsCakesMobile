class CurrencyFormatter {
  static const String _currency = 'XAF';

  /// Format amount for display (assumes amount is in major currency units)
  static String format(dynamic amount) {
    if (amount == null) return '0 $_currency';

    // Convert to double if it's not already
    double value;
    if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else {
      value = 0.0;
    }

    // For XAF, we don't use decimal places for whole amounts
    return '${value.toStringAsFixed(0)} $_currency';
  }

  /// Format amount from minor units (cents) to major units and display
  static String formatFromMinorUnits(dynamic amountInMinorUnits) {
    if (amountInMinorUnits == null) return '0 $_currency';

    // Convert to double if it's not already
    double value;
    if (amountInMinorUnits is int) {
      value = amountInMinorUnits.toDouble();
    } else if (amountInMinorUnits is double) {
      value = amountInMinorUnits;
    } else if (amountInMinorUnits is String) {
      value = double.tryParse(amountInMinorUnits) ?? 0.0;
    } else {
      value = 0.0;
    }

    // Convert from minor units to major units (divide by 100)
    double majorUnits = value / 100;

    return '${majorUnits.toStringAsFixed(0)} $_currency';
  }

  /// Convert major units to minor units for payment processing
  static int toMinorUnits(dynamic amount) {
    if (amount == null) return 0;

    double value;
    if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else {
      value = 0.0;
    }

    return (value * 100).round();
  }

  /// Convert minor units to major units
  static double fromMinorUnits(dynamic amountInMinorUnits) {
    if (amountInMinorUnits == null) return 0.0;

    double value;
    if (amountInMinorUnits is int) {
      value = amountInMinorUnits.toDouble();
    } else if (amountInMinorUnits is double) {
      value = amountInMinorUnits;
    } else if (amountInMinorUnits is String) {
      value = double.tryParse(amountInMinorUnits) ?? 0.0;
    } else {
      value = 0.0;
    }

    return value / 100;
  }
}
