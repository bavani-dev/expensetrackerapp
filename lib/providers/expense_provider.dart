import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../services/notification_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];

  double _monthlyBudget = 0;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  // ============================================================
  // TOTAL EXPENSES
  // ============================================================

  double get totalExpenses {
    return _expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  // ============================================================
  // MONTHLY BUDGET
  // ============================================================

  double get monthlyBudget => _monthlyBudget;

  // ============================================================
  // CURRENT MONTH EXPENSES
  // ============================================================

  double get currentMonthExpenses {
    final DateTime now = DateTime.now();

    return _expenses
        .where(
          (expense) =>
              expense.date.year == now.year &&
              expense.date.month == now.month,
        )
        .fold(
          0,
          (sum, expense) => sum + expense.amount,
        );
  }

  // ============================================================
  // REMAINING BUDGET
  // ============================================================

  double get remainingBudget {
    if (_monthlyBudget <= 0) {
      return 0;
    }

    return _monthlyBudget - currentMonthExpenses;
  }

  // ============================================================
  // BUDGET PERCENTAGE
  // ============================================================

  double get budgetPercentage {
    if (_monthlyBudget <= 0) {
      return 0;
    }

    return (currentMonthExpenses / _monthlyBudget)
        .clamp(0.0, 1.0);
  }

  // ============================================================
  // BUDGET EXCEEDED
  // ============================================================

  bool get isBudgetExceeded {
    return _monthlyBudget > 0 &&
        currentMonthExpenses >= _monthlyBudget;
  }

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ExpenseProvider() {
    loadExpenses();
    loadBudget();
  }

  // ============================================================
  // LOAD EXPENSES
  // ============================================================

  Future<void> loadExpenses() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> savedExpenses =
        prefs.getStringList('expenses') ?? [];

    _expenses.clear();

    for (final String item in savedExpenses) {
      final List<String> parts = item.split('|');

      if (parts.length >= 4) {
        final double? amount =
            double.tryParse(parts[0]);

        if (amount != null) {
          String? receiptData;

          if (parts.length >= 5 &&
              parts[4].isNotEmpty) {
            receiptData = parts[4];
          }

          try {
            _expenses.add(
              Expense(
                amount: amount,
                category: parts[1],
                description: parts[2],
                date: DateTime.parse(parts[3]),
                receiptData: receiptData,
              ),
            );
          } catch (_) {
            // Ignore invalid saved expense
          }
        }
      }
    }

    notifyListeners();
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);

    // Save expense first
    await saveExpenses();

    // ==========================================================
    // CHECK MONTHLY BUDGET
    // ==========================================================

    final double budget = monthlyBudget;
    final double spent = currentMonthExpenses;

    if (budget > 0) {
      await NotificationService.showBudgetWarning(
        spent: spent,
        budget: budget,
      );
    }

    notifyListeners();
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> deleteExpense(int index) async {
    _expenses.removeAt(index);

    await saveExpenses();

    notifyListeners();
  }

  // ============================================================
  // SAVE EXPENSES
  // ============================================================

  Future<void> saveExpenses() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> savedExpenses =
        _expenses.map((expense) {
      return '${expense.amount}|'
          '${expense.category}|'
          '${expense.description}|'
          '${expense.date.toIso8601String()}|'
          '${expense.receiptData ?? ''}';
    }).toList();

    await prefs.setStringList(
      'expenses',
      savedExpenses,
    );
  }

  // ============================================================
  // SET MONTHLY BUDGET
  // ============================================================

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setDouble(
      'monthly_budget',
      amount,
    );

    notifyListeners();
  }

  // ============================================================
  // LOAD MONTHLY BUDGET
  // ============================================================

  Future<void> loadBudget() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    _monthlyBudget =
        prefs.getDouble('monthly_budget') ?? 0;

    notifyListeners();
  }

  // ============================================================
  // CLEAR MONTHLY BUDGET
  // ============================================================

  Future<void> clearBudget() async {
    _monthlyBudget = 0;

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('monthly_budget');

    notifyListeners();
  }
}