import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../add_expense/add_expense_screen.dart';
import '../analytics/analytics_screen.dart';
import '../budget/budget_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      body: SafeArea(
        child: Consumer2<ExpenseProvider, IncomeProvider>(
          builder: (
            context,
            expenseProvider,
            incomeProvider,
            child,
          ) {
            final double totalIncome =
                incomeProvider.totalIncome;

            final double totalExpenses =
                expenseProvider.totalExpenses;

            final double balance =
                totalIncome - totalExpenses;

            final DateTime now = DateTime.now();

            final double monthlyExpense =
                expenseProvider.expenses
                    .where(
                      (expense) =>
                          expense.date.month == now.month &&
                          expense.date.year == now.year,
                    )
                    .fold(
                      0.0,
                      (sum, expense) => sum + expense.amount,
                    );

            // Budget information
            final double monthlyBudget =
                expenseProvider.monthlyBudget;

            final double budgetSpent =
                expenseProvider.currentMonthExpenses;

            final double budgetRemaining =
                expenseProvider.remainingBudget;

            final double budgetPercentage =
                expenseProvider.budgetPercentage;

            final bool hasBudget =
                monthlyBudget > 0;

            final bool budgetExceeded =
                expenseProvider.isBudgetExceeded;

            final recentExpenses =
                expenseProvider.expenses.toList()
                  ..sort(
                    (a, b) => b.date.compareTo(a.date),
                  );

            final recentIncomes =
                incomeProvider.incomes.toList()
                  ..sort(
                    (a, b) => b.date.compareTo(a.date),
                  );

            return RefreshIndicator(
              onRefresh: () async {
                await expenseProvider.loadExpenses();
                await incomeProvider.loadIncomes();
              },

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  100,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ======================================================
                    // HEADER
                    // ======================================================

                    Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: const [

                              Text(
                                'Welcome back 👋',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'My Finances',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 46,
                          height: 46,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(15),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset:
                                    const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons
                                .notifications_none_rounded,
                            color:
                                Color(0xFF20242A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // BALANCE CARD
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF20A4F3),
                            Color(0xFF1677C8),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(26),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF20A4F3)
                                .withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset:
                                const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              const Text(
                                'Available Balance',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.all(8),

                                decoration:
                                    BoxDecoration(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),

                                child: const Icon(
                                  Icons
                                      .account_balance_wallet_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '₹ ${balance.toStringAsFixed(2)}',

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            balance >= 0
                                ? 'Your finances are looking good'
                                : 'Your expenses are higher than income',

                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [

                              Expanded(
                                child: _balanceItem(
                                  icon:
                                      Icons.arrow_downward,
                                  title: 'Income',
                                  amount: totalIncome,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _balanceItem(
                                  icon:
                                      Icons.arrow_upward,
                                  title: 'Expenses',
                                  amount: totalExpenses,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ======================================================
                    // QUICK STATISTICS
                    // ======================================================

                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child: _statCard(
                            icon:
                                Icons.trending_up_rounded,
                            title: 'Income',
                            amount: totalIncome,
                            iconColor:
                                const Color(0xFF22B573),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _statCard(
                            icon:
                                Icons.trending_down_rounded,
                            title: 'Expenses',
                            amount: totalExpenses,
                            iconColor:
                                const Color(0xFFE85D5D),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ======================================================
                    // MONTHLY EXPENSE CARD
                    // ======================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.035),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF20A4F3)
                                      .withValues(
                                alpha: 0.1,
                              ),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color:
                                  Color(0xFF20A4F3),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Text(
                                  'This Month',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  '₹ ${monthlyExpense.toStringAsFixed(2)}',

                                  style:
                                      const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF20A4F3)
                                      .withValues(
                                alpha: 0.08,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),

                            child: const Text(
                              'Spending',
                              style: TextStyle(
                                color:
                                    Color(0xFF20A4F3),
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ======================================================
                    // BUDGET PROGRESS
                    // ======================================================

                    if (hasBudget)
                      _budgetProgressCard(
                        context: context,
                        budget: monthlyBudget,
                        spent: budgetSpent,
                        remaining: budgetRemaining,
                        percentage:
                            budgetPercentage,
                        exceeded:
                            budgetExceeded,
                      ),

                    if (hasBudget)
                      const SizedBox(height: 25),

                    // ======================================================
                    // QUICK ACTIONS
                    // ======================================================

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child: _quickAction(
                            context: context,
                            icon: Icons.add_rounded,
                            title: 'Add Expense',
                            color:
                                const Color(0xFF20A4F3),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddExpenseScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _quickAction(
                            context: context,
                            icon:
                                Icons.bar_chart_rounded,
                            title: 'Analytics',
                            color:
                                const Color(0xFF8E6CEF),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AnalyticsScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _quickAction(
                            context: context,
                            icon: Icons
                                .account_balance_wallet_rounded,
                            title: 'Budget',
                            color:
                                const Color(0xFFFFA726),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BudgetScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // RECENT TRANSACTIONS
                    // ======================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          '${recentExpenses.length + recentIncomes.length} total',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (recentExpenses.isEmpty &&
                        recentIncomes.isEmpty)

                      _emptyTransactions()

                    else

                      ..._buildRecentTransactions(
                        recentExpenses,
                        recentIncomes,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // ================================================================
      // FLOATING ADD BUTTON
      // ================================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AddExpenseScreen(),
            ),
          );
        },

        backgroundColor:
            const Color(0xFF20A4F3),

        foregroundColor: Colors.white,

        elevation: 6,

        icon: const Icon(Icons.add_rounded),

        label: const Text(
          'Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUDGET PROGRESS CARD
  // ============================================================

  Widget _budgetProgressCard({
    required BuildContext context,
    required double budget,
    required double spent,
    required double remaining,
    required double percentage,
    required bool exceeded,
  }) {
    final double progress =
        percentage.clamp(0.0, 1.0).toDouble();

    final Color statusColor = exceeded
        ? const Color(0xFFE85D5D)
        : const Color(0xFFFFA726);

    return InkWell(
      borderRadius: BorderRadius.circular(22),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const BudgetScreen(),
          ),
        );
      },

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.035),
              blurRadius: 12,
              offset:
                  const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                Container(
                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    color: statusColor
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),

                  child: Icon(
                    Icons
                        .account_balance_wallet_rounded,
                    color: statusColor,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '₹ ${budget.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  'Budget usage',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                Text(
                  '${(percentage * 100).clamp(0, double.infinity).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),

              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor:
                    Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  statusColor,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [

                Expanded(
                  child: _budgetSmallInfo(
                    title: 'Spent',
                    value:
                        '₹ ${spent.toStringAsFixed(0)}',
                    color:
                        const Color(0xFFE85D5D),
                  ),
                ),

                Expanded(
                  child: _budgetSmallInfo(
                    title: exceeded
                        ? 'Exceeded'
                        : 'Remaining',
                    value:
                        '₹ ${remaining.abs().toStringAsFixed(0)}',
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              exceeded
                  ? '⚠ You have exceeded your monthly budget'
                  : 'Tap to manage your monthly budget',
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUDGET SMALL INFO
  // ============================================================

  Widget _budgetSmallInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BALANCE ITEM
  // ============================================================

  Widget _balanceItem({
    required IconData icon,
    required String title,
    required double amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: 0.13),
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '₹ ${amount.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.035),
            blurRadius: 12,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color:
                  iconColor.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION
  // ============================================================

  Widget _quickAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 12,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.035),
              blurRadius: 10,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color:
                    color.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY TRANSACTIONS
  // ============================================================

  Widget _emptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        children: [

          Icon(
            Icons.receipt_long_outlined,
            size: 52,
            color: Colors.grey,
          ),

          SizedBox(height: 12),

          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Add your first income or expense.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT TRANSACTIONS
  // ============================================================

  List<Widget> _buildRecentTransactions(
    List expenses,
    List incomes,
  ) {
    final List<Map<String, dynamic>>
        transactions = [];

    for (final income in incomes) {
      transactions.add({
        'type': 'income',
        'amount': income.amount,
        'title': income.source,
        'description': income.description,
        'date': income.date,
      });
    }

    for (final expense in expenses) {
      transactions.add({
        'type': 'expense',
        'amount': expense.amount,
        'title': expense.category,
        'description': expense.description,
        'date': expense.date,
      });
    }

    transactions.sort(
      (a, b) =>
          (b['date'] as DateTime)
              .compareTo(
            a['date'] as DateTime,
          ),
    );

    final displayed =
        transactions.take(5).toList();

    return displayed.map((transaction) {

      final bool isIncome =
          transaction['type'] == 'income';

      final double amount =
          transaction['amount'] as double;

      final DateTime date =
          transaction['date'] as DateTime;

      final String title =
          transaction['title'] as String;

      final String description =
          transaction['description'] as String;

      return Container(
        margin:
            const EdgeInsets.only(bottom: 10),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.03),
              blurRadius: 10,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: (isIncome
                        ? const Color(0xFF22B573)
                        : const Color(0xFFE85D5D))
                    .withValues(alpha: 0.1),

                borderRadius:
                    BorderRadius.circular(13),
              ),

              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,

                color: isIncome
                    ? const Color(0xFF22B573)
                    : const Color(0xFFE85D5D),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description.isEmpty
                        ? 'No description'
                        : description,

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${date.day}/${date.month}/${date.year}',

                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${isIncome ? '+' : '-'} ₹ ${amount.toStringAsFixed(2)}',

              style: TextStyle(
                color: isIncome
                    ? const Color(0xFF22B573)
                    : const Color(0xFFE85D5D),

                fontWeight:
                    FontWeight.bold,

                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}