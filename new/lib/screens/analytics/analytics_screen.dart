import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.expenses;
          final totalExpenses = provider.totalExpenses;

          final categoryTotals = <String, double>{};

          for (final expense in expenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) +
                    expense.amount;
          }

          final sortedCategories = categoryTotals.entries.toList()
            ..sort(
              (a, b) => b.value.compareTo(a.value),
            );

          final now = DateTime.now();

          double thisMonthExpense = 0;

          for (final expense in expenses) {
            if (expense.date.month == now.month &&
                expense.date.year == now.year) {
              thisMonthExpense += expense.amount;
            }
          }

          final averageMonthly = _calculateAverageMonthly(expenses);

          final highestCategory = sortedCategories.isNotEmpty
              ? sortedCategories.first.key
              : 'No data';

          final highestCategoryAmount = sortedCategories.isNotEmpty
              ? sortedCategories.first.value
              : 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadExpenses();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  const Text(
                    'Financial Overview',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Understand where your money is going',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // TOTAL EXPENSE CARD
                  _buildTotalCard(
                    totalExpenses,
                    expenses.length,
                  ),

                  const SizedBox(height: 18),

                  // SUMMARY CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallStatCard(
                          title: 'This Month',
                          value: '₹${thisMonthExpense.toStringAsFixed(0)}',
                          icon: Icons.calendar_month_outlined,
                          iconColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallStatCard(
                          title: 'Transactions',
                          value: '${expenses.length}',
                          icon: Icons.receipt_long_outlined,
                          iconColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallStatCard(
                          title: 'Monthly Average',
                          value: '₹${averageMonthly.toStringAsFixed(0)}',
                          icon: Icons.trending_up_outlined,
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallStatCard(
                          title: 'Top Category',
                          value: highestCategory,
                          icon: _getCategoryIcon(highestCategory),
                          iconColor: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // CATEGORY SECTION
                  const Text(
                    'Spending by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'See which categories use most of your money',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (categoryTotals.isEmpty)
                    _buildEmptyCard()
                  else
                    _buildCategoryChart(
                      categoryTotals,
                      totalExpenses,
                    ),

                  const SizedBox(height: 18),

                  // TOP CATEGORY HIGHLIGHT
                  if (sortedCategories.isNotEmpty)
                    _buildTopCategoryCard(
                      highestCategory,
                      highestCategoryAmount,
                      totalExpenses,
                    ),

                  const SizedBox(height: 20),

                  // CATEGORY LIST
                  if (sortedCategories.isNotEmpty)
                    ...sortedCategories.map(
                      (entry) {
                        final percentage = totalExpenses > 0
                            ? (entry.value / totalExpenses) * 100
                            : 0.0;

                        return _buildCategoryItem(
                          category: entry.key,
                          amount: entry.value,
                          percentage: percentage,
                        );
                      },
                    ),

                  const SizedBox(height: 28),

                  // MONTHLY CHART
                  const Text(
                    'Monthly Spending',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Your expense trend over the last 6 months',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildMonthlyChart(expenses),

                  const SizedBox(height: 25),

                  // INSIGHT CARD
                  if (expenses.isNotEmpty)
                    _buildInsightCard(
                      highestCategory,
                      highestCategoryAmount,
                      totalExpenses,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TOTAL EXPENSE CARD
  // ------------------------------------------------------------

  Widget _buildTotalCard(
    double total,
    int transactionCount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Expenses',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            '₹ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$transactionCount transaction${transactionCount == 1 ? '' : 's'} recorded',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SMALL STAT CARD
  // ------------------------------------------------------------

  Widget _buildSmallStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY PIE CHART
  // ------------------------------------------------------------

  Widget _buildCategoryChart(
    Map<String, double> categoryTotals,
    double total,
  ) {
    final entries = categoryTotals.entries.toList();

    return Container(
      width: double.infinity,
      height: 310,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 58,
                sectionsSpace: 4,
                sections: List.generate(
                  entries.length,
                  (index) {
                    final entry = entries[index];

                    final percentage = total > 0
                        ? (entry.value / total) * 100
                        : 0;

                    return PieChartSectionData(
                      value: entry.value,
                      title:
                          '${percentage.toStringAsFixed(0)}%',
                      radius: 88,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: entries.map(
              (entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP CATEGORY CARD
  // ------------------------------------------------------------

  Widget _buildTopCategoryCard(
    String category,
    double amount,
    double total,
  ) {
    final percentage =
        total > 0 ? (amount / total) * 100 : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: Colors.blue,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Highest Spending',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY ITEM
  // ------------------------------------------------------------

  Widget _buildCategoryItem({
    required String category,
    required double amount,
    required double percentage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: Colors.blue,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 7),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 5,
                    backgroundColor:
                        Colors.grey.withValues(alpha: 0.12),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${percentage.toStringAsFixed(1)}% of total spending',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MONTHLY BAR CHART
  // ------------------------------------------------------------

  Widget _buildMonthlyChart(List expenses) {
    final now = DateTime.now();

    final List<Map<String, dynamic>> months = [];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month - i,
      );

      double amount = 0;

      for (final expense in expenses) {
        if (expense.date.month == date.month &&
            expense.date.year == date.year) {
          amount += expense.amount;
        }
      }

      months.add({
        'month': date,
        'amount': amount,
      });
    }

    double maxAmount = 0;

    for (final item in months) {
      final amount = item['amount'] as double;

      if (amount > maxAmount) {
        maxAmount = amount;
      }
    }

    final chartMax = maxAmount <= 0
        ? 100.0
        : maxAmount * 1.25;

    return Container(
      width: double.infinity,
      height: 330,
      padding: const EdgeInsets.fromLTRB(
        5,
        20,
        18,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: chartMax,

          minY: 0,

          alignment: BarChartAlignment.spaceAround,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMax / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                strokeWidth: 0.8,
                color: Colors.grey.withValues(alpha: 0.15),
              );
            },
          ),

          borderData: FlBorderData(
            show: false,
          ),

          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem:
                  (group, groupIndex, rod, rodIndex) {
                final amount = rod.toY;

                return BarTooltipItem(
                  '₹${amount.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: chartMax / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${_formatChartAmount(value)}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 ||
                      index >= months.length) {
                    return const SizedBox();
                  }

                  final date =
                      months[index]['month'] as DateTime;

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      _shortMonth(date.month),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: List.generate(
            months.length,
            (index) {
              final amount =
                  months[index]['amount'] as double;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: amount,
                    width: 25,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INSIGHT CARD
  // ------------------------------------------------------------

  Widget _buildInsightCard(
    String category,
    double amount,
    double total,
  ) {
    final percentage =
        total > 0 ? (amount / total) * 100 : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.orange,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spending Insight',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$category is your highest spending category, '
                  'accounting for ${percentage.toStringAsFixed(1)}% '
                  'of your total expenses.',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 55,
            color: Colors.grey,
          ),

          SizedBox(height: 12),

          Text(
            'No expense data yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Add expenses to see your analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // AVERAGE MONTHLY EXPENSE
  // ------------------------------------------------------------

  double _calculateAverageMonthly(List expenses) {
    if (expenses.isEmpty) {
      return 0;
    }

    final Map<String, double> monthlyTotals = {};

    for (final expense in expenses) {
      final key =
          '${expense.date.year}-${expense.date.month}';

      monthlyTotals[key] =
          (monthlyTotals[key] ?? 0) + expense.amount;
    }

    if (monthlyTotals.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final amount in monthlyTotals.values) {
      total += amount;
    }

    return total / monthlyTotals.length;
  }

  // ------------------------------------------------------------
  // CHART AMOUNT FORMAT
  // ------------------------------------------------------------

  String _formatChartAmount(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(0);
  }

  // ------------------------------------------------------------
  // MONTH NAME
  // ------------------------------------------------------------

  String _shortMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // ------------------------------------------------------------
  // CATEGORY ICON
  // ------------------------------------------------------------

  IconData _getCategoryIcon(String category) {
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
        return Icons.category_outlined;
    }
  }
}