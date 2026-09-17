import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../add_expense/add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'All';
  String selectedMonth = 'All';

  final List<String> categories = [
    'All',
    'Food',
    'Shopping',
    'Travel',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  bool isSameMonth(DateTime date, String month) {
    if (month == 'All') {
      return true;
    }

    final parts = month.split(' ');

    if (parts.length != 2) {
      return true;
    }

    final int? monthNumber = int.tryParse(parts[0]);
    final int? year = int.tryParse(parts[1]);

    if (monthNumber == null || year == null) {
      return true;
    }

    return date.month == monthNumber &&
        date.year == year;
  }

  List<String> getMonthOptions() {
    final now = DateTime.now();
    final List<String> months = ['All'];

    for (int i = 0; i < 12; i++) {
      final date = DateTime(
        now.year,
        now.month - i,
      );

      final value =
          '${date.month} ${date.year}';

      if (!months.contains(value)) {
        months.add(value);
      }
    }

    return months;
  }

  String formatMonth(String month) {
    if (month == 'All') {
      return 'All Months';
    }

    final parts = month.split(' ');

    if (parts.length != 2) {
      return month;
    }

    final int? monthNumber =
        int.tryParse(parts[0]);

    final int? year =
        int.tryParse(parts[1]);

    if (monthNumber == null || year == null) {
      return month;
    }

    return '${monthName(monthNumber)} $year';
  }

  // Convert Base64 receipt data into image bytes.
  Uint8List? decodeReceipt(String receiptData) {
    try {
      return base64Decode(receiptData);
    } catch (_) {
      return null;
    }
  }

  // Show receipt image.
  void showReceipt(String receiptData) {
    final Uint8List? imageBytes =
        decodeReceipt(receiptData);

    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open this receipt',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.all(15),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 700,
              maxWidth: 600,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    15,
                    10,
                    10,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Bill / Receipt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Padding(
                  padding:
                      EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Pinch or scroll to zoom',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor:
            const Color(0xFFF6F8FB),
        elevation: 0,
      ),

      body: Consumer<ExpenseProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final searchText =
              searchController.text
                  .toLowerCase()
                  .trim();

          final filteredExpenses =
              provider.expenses.where(
            (expense) {
              final matchesSearch =
                  expense.category
                          .toLowerCase()
                          .contains(searchText) ||
                      expense.description
                          .toLowerCase()
                          .contains(searchText);

              final matchesCategory =
                  selectedCategory == 'All' ||
                      expense.category ==
                          selectedCategory;

              final matchesMonth =
                  isSameMonth(
                expense.date,
                selectedMonth,
              );

              return matchesSearch &&
                  matchesCategory &&
                  matchesMonth;
            },
          ).toList();

          filteredExpenses.sort(
            (a, b) =>
                b.date.compareTo(a.date),
          );

          final filteredTotal =
              filteredExpenses.fold<double>(
            0,
            (sum, expense) =>
                sum + expense.amount,
          );

          final monthOptions =
              getMonthOptions();

          return Column(
            children: [
              // SEARCH
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  12,
                ),
                child: TextField(
                  controller:
                      searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration:
                      InputDecoration(
                    hintText:
                        'Search expenses...',
                    prefixIcon:
                        const Icon(
                      Icons.search,
                      color:
                          Color(0xFF20A4F3),
                    ),
                    suffixIcon:
                        searchController
                                .text
                                .isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  searchController
                                      .clear();

                                  setState(
                                    () {},
                                  );
                                },
                              )
                            : null,
                  ),
                ),
              ),

              // MONTH FILTER
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child:
                      DropdownButtonHideUnderline(
                    child:
                        DropdownButton<String>(
                      value:
                          selectedMonth,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.calendar_month,
                        color:
                            Color(0xFF20A4F3),
                      ),
                      items:
                          monthOptions.map(
                        (month) {
                          return DropdownMenuItem<
                              String>(
                            value: month,
                            child: Text(
                              formatMonth(
                                month,
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth =
                                value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // CATEGORY FILTER
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount:
                      categories.length,
                  itemBuilder:
                      (context, index) {
                    final category =
                        categories[index];

                    final isSelected =
                        selectedCategory ==
                            category;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label:
                            Text(category),
                        selected:
                            isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory =
                                category;
                          });
                        },
                        selectedColor:
                            const Color(
                          0xFF20A4F3,
                        ),
                        labelStyle:
                            TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight:
                              FontWeight.w600,
                        ),
                        backgroundColor:
                            Colors.white,
                        side:
                            BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // TOTAL EXPENSE CARD
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF20A4F3,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(
                          0xFF20A4F3,
                        ).withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 15,
                        offset:
                            const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.18,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons.trending_down,
                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Total Expenses',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              '${filteredExpenses.length} transaction${filteredExpenses.length == 1 ? '' : 's'}',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Flexible(
                        child: Text(
                          '₹ ${filteredTotal.toStringAsFixed(2)}',
                          textAlign:
                              TextAlign.end,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // EXPENSE LIST
              Expanded(
                child:
                    filteredExpenses.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons
                                      .receipt_long_outlined,
                                  size: 64,
                                  color:
                                      Colors.grey,
                                ),

                                SizedBox(
                                  height: 14,
                                ),

                                Text(
                                  'No expenses found',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  'Add an expense or try another filter',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              20,
                              0,
                              20,
                              90,
                            ),
                            itemCount:
                                filteredExpenses
                                    .length,
                            itemBuilder:
                                (context, index) {
                              final expense =
                                  filteredExpenses[
                                      index];

                              final originalIndex =
                                  provider
                                      .expenses
                                      .indexOf(
                                expense,
                              );

                              return Dismissible(
                                key: ValueKey(
                                  '${expense.date}_${expense.amount}_${expense.category}_$originalIndex',
                                ),

                                direction:
                                    DismissDirection
                                        .endToStart,

                                background:
                                    Container(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    right: 20,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.red,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      18,
                                    ),
                                  ),
                                  alignment:
                                      Alignment
                                          .centerRight,
                                  child:
                                      const Icon(
                                    Icons
                                        .delete_outline,
                                    color:
                                        Colors.white,
                                    size: 26,
                                  ),
                                ),

                                confirmDismiss:
                                    (_) async {
                                  return await showDialog<
                                          bool>(
                                        context:
                                            context,
                                        builder:
                                            (
                                          dialogContext,
                                        ) {
                                          return AlertDialog(
                                            title:
                                                const Text(
                                              'Delete Expense?',
                                            ),
                                            content:
                                                const Text(
                                              'Are you sure you want to delete this expense?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () {
                                                  Navigator.pop(
                                                    dialogContext,
                                                    false,
                                                  );
                                                },
                                                child:
                                                    const Text(
                                                  'Cancel',
                                                ),
                                              ),
                                              ElevatedButton(
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red,
                                                ),
                                                onPressed:
                                                    () {
                                                  Navigator.pop(
                                                    dialogContext,
                                                    true,
                                                  );
                                                },
                                                child:
                                                    const Text(
                                                  'Delete',
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false;
                                },

                                onDismissed:
                                    (_) async {
                                  await provider
                                      .deleteExpense(
                                    originalIndex,
                                  );
                                },

                                child:
                                    Container(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .all(
                                    16,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      18,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius:
                                            10,
                                        offset:
                                            const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .red
                                              .withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            14,
                                          ),
                                        ),
                                        child:
                                            Icon(
                                          _getExpenseIcon(
                                            expense
                                                .category,
                                          ),
                                          color:
                                              Colors.red,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 14,
                                      ),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              expense
                                                  .category,
                                              maxLines:
                                                  1,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize:
                                                    16,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 5,
                                            ),

                                            Text(
                                              expense
                                                      .description
                                                      .isEmpty
                                                  ? 'No description'
                                                  : expense
                                                      .description,
                                              maxLines:
                                                  1,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.grey,
                                                fontSize:
                                                    12,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 5,
                                            ),

                                            Text(
                                              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.grey,
                                                fontSize:
                                                    11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .end,
                                        children: [
                                          Text(
                                            '- ₹ ${expense.amount.toStringAsFixed(2)}',
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.red,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize:
                                                  14,
                                            ),
                                          ),

                                          // RECEIPT ICON
                                          if (expense
                                                  .receiptData !=
                                              null &&
                                              expense
                                                  .receiptData!
                                                  .isNotEmpty) ...[
                                            const SizedBox(
                                              height: 8,
                                            ),

                                            InkWell(
                                              onTap:
                                                  () {
                                                showReceipt(
                                                  expense
                                                      .receiptData!,
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                10,
                                              ),
                                              child:
                                                  Container(
                                                padding:
                                                    const EdgeInsets
                                                        .all(
                                                  7,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      const Color(
                                                    0xFF20A4F3,
                                                  ).withValues(
                                                    alpha:
                                                        0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                    10,
                                                  ),
                                                ),
                                                child:
                                                    const Icon(
                                                  Icons
                                                      .receipt_long_outlined,
                                                  size:
                                                      20,
                                                  color:
                                                      Color(
                                                    0xFF20A4F3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),

      // ADD EXPENSE
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFF20A4F3),
        foregroundColor:
            Colors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AddExpenseScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }

  IconData _getExpenseIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;

      case 'Shopping':
        return Icons.shopping_bag_outlined;

      case 'Travel':
        return Icons.flight_outlined;

      case 'Entertainment':
        return Icons.movie_outlined;

      case 'Bills':
        return Icons.receipt_long_outlined;

      case 'Health':
        return Icons.health_and_safety_outlined;

      case 'Other':
        return Icons.more_horiz_outlined;

      default:
        return Icons.receipt_long_outlined;
    }
  }
}