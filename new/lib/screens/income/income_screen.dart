import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/income_provider.dart';
import 'add_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedSource = 'All';
  String selectedMonth = 'All';

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

  List<String> getMonthOptions() {
    final now = DateTime.now();

    final List<String> months = ['All'];

    for (int i = 0; i < 12; i++) {
      final date = DateTime(
        now.year,
        now.month - i,
      );

      final value = '${date.month} ${date.year}';

      if (!months.contains(value)) {
        months.add(value);
      }
    }

    return months;
  }

  String formatMonth(String value) {
    if (value == 'All') {
      return 'All';
    }

    final parts = value.split(' ');

    if (parts.length != 2) {
      return value;
    }

    final int? month = int.tryParse(parts[0]);
    final int? year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return value;
    }

    return '${monthName(month)} $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'Income',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF6F8FB),
        elevation: 0,
      ),

      body: Consumer<IncomeProvider>(
        builder: (context, provider, child) {
          final searchText =
              searchController.text.toLowerCase().trim();

          final sources = <String>[
            'All',
            ...provider.incomes
                .map((income) => income.source)
                .where((source) => source.isNotEmpty)
                .toSet(),
          ];

          if (!sources.contains(selectedSource)) {
            selectedSource = 'All';
          }

          final filteredIncomes =
              provider.incomes.where((income) {
            final matchesSearch =
                income.source
                        .toLowerCase()
                        .contains(searchText) ||
                    income.description
                        .toLowerCase()
                        .contains(searchText);

            final matchesSource =
                selectedSource == 'All' ||
                    income.source == selectedSource;

            bool matchesMonth = true;

            if (selectedMonth != 'All') {
              final parts = selectedMonth.split(' ');

              if (parts.length == 2) {
                final selectedMonthNumber =
                    int.tryParse(parts[0]);

                final selectedYear =
                    int.tryParse(parts[1]);

                matchesMonth =
                    selectedMonthNumber != null &&
                        selectedYear != null &&
                        income.date.month ==
                            selectedMonthNumber &&
                        income.date.year ==
                            selectedYear;
              }
            }

            return matchesSearch &&
                matchesSource &&
                matchesMonth;
          }).toList();

          filteredIncomes.sort(
            (a, b) => b.date.compareTo(a.date),
          );

          final filteredTotal =
              filteredIncomes.fold<double>(
            0,
            (sum, income) => sum + income.amount,
          );

          final monthOptions = getMonthOptions();

          return Column(
            children: [
              // SEARCH
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  12,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search income...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF22B573),
                    ),
                    suffixIcon:
                        searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                  ),
                ),
              ),

              // MONTH FILTER
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: monthOptions.length,
                  itemBuilder: (context, index) {
                    final month = monthOptions[index];

                    final isSelected =
                        selectedMonth == month;

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(
                          formatMonth(month),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedMonth = month;
                          });
                        },
                        selectedColor:
                            const Color(0xFF22B573),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // SOURCE FILTER
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: sources.length,
                  itemBuilder: (context, index) {
                    final source = sources[index];

                    final isSelected =
                        selectedSource == source;

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(source),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedSource = source;
                          });
                        },
                        selectedColor:
                            const Color(0xFF22B573),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // TOTAL INCOME CARD
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22B573),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22B573)
                            .withValues(alpha: 0.18),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.18),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Income',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${filteredIncomes.length} transaction${filteredIncomes.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Text(
                          '₹ ${filteredTotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // INCOME LIST
              Expanded(
                child: filteredIncomes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons
                                  .account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No income found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add income or try another filter',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          90,
                        ),
                        itemCount:
                            filteredIncomes.length,
                        itemBuilder: (context, index) {
                          final income =
                              filteredIncomes[index];

                          final originalIndex =
                              provider.incomes.indexOf(
                            income,
                          );

                          return Dismissible(
                            key: ValueKey(
                              '${income.date}_${income.amount}_${income.source}_$originalIndex',
                            ),
                            direction:
                                DismissDirection.endToStart,

                            background: Container(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              padding:
                                  const EdgeInsets.only(
                                right: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                              alignment:
                                  Alignment.centerRight,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),

                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (dialogContext) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Delete Income?',
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this income?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
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
                                                ElevatedButton
                                                    .styleFrom(
                                              backgroundColor:
                                                  Colors.red,
                                            ),
                                            onPressed: () {
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

                            onDismissed: (_) async {
                              await provider.deleteIncome(
                                originalIndex,
                              );
                            },

                            child: Container(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              padding:
                                  const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 10,
                                    offset:
                                        const Offset(0, 4),
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
                                      color:
                                          const Color(
                                        0xFF22B573,
                                      ).withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .account_balance_wallet_outlined,
                                      color:
                                          Color(0xFF22B573),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          income.source,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 5,
                                        ),

                                        Text(
                                          income.description
                                                  .isEmpty
                                              ? 'No description'
                                              : income
                                                  .description,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 5,
                                        ),

                                        Text(
                                          '${income.date.day}/${income.date.month}/${income.date.year}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    '+ ₹ ${income.amount.toStringAsFixed(2)}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(0xFF22B573),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 14,
                                    ),
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

      // ADD INCOME
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22B573),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AddIncomeScreen(),
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
}