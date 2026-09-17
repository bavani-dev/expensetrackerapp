import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Income {
  final double amount;
  final String source;
  final String description;
  final DateTime date;

  Income({
    required this.amount,
    required this.source,
    required this.description,
    required this.date,
  });
}

class IncomeProvider extends ChangeNotifier {
  final List<Income> _incomes = [];

  List<Income> get incomes => List.unmodifiable(_incomes);

  double get totalIncome {
    return _incomes.fold(
      0,
      (sum, income) => sum + income.amount,
    );
  }

  IncomeProvider() {
    loadIncomes();
  }

  Future<void> loadIncomes() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> savedIncomes =
        prefs.getStringList('incomes') ?? [];

    _incomes.clear();

    for (final String item in savedIncomes) {
      final List<String> parts = item.split('|');

      if (parts.length == 4) {
        final double? amount = double.tryParse(parts[0]);

        if (amount != null) {
          _incomes.add(
            Income(
              amount: amount,
              source: parts[1],
              description: parts[2],
              date: DateTime.parse(parts[3]),
            ),
          );
        }
      }
    }

    notifyListeners();
  }

  Future<void> addIncome(Income income) async {
    _incomes.add(income);

    await saveIncomes();

    notifyListeners();
  }

  Future<void> deleteIncome(int index) async {
    _incomes.removeAt(index);

    await saveIncomes();

    notifyListeners();
  }

  Future<void> saveIncomes() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> savedIncomes =
        _incomes.map((income) {
      return '${income.amount}|'
          '${income.source}|'
          '${income.description}|'
          '${income.date.toIso8601String()}';
    }).toList();

    await prefs.setStringList(
      'incomes',
      savedIncomes,
    );
  }
}