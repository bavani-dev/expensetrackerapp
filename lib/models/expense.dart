class Expense {
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  // Base64 encoded receipt image.
  final String? receiptData;

  Expense({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.receiptData,
  });
}