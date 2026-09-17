import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        title: const Text(
          'Budget',
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
          final budget = provider.monthlyBudget;
          final spent = provider.currentMonthExpenses;
          final remaining = provider.remainingBudget;

          double progress = provider.budgetPercentage;

          if (progress > 1) {
            progress = 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Track your spending and stay within your budget',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                // MAIN BUDGET CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1565C0),
                        Color(0xFF42A5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(
                          alpha: 0.20,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
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
                            padding:
                                const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Text(
                            'This Month',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Budget',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '₹ ${budget.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 22),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor:
                              Colors.white.withValues(
                            alpha: 0.20,
                          ),
                          valueColor:
                              const AlwaysStoppedAnimation<
                                  Color>(
                            Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(provider.budgetPercentage * 100).toStringAsFixed(1)}% used',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '₹${spent.toStringAsFixed(0)} spent',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // STATUS
                if (budget <= 0)
                  _buildNoBudgetCard(
                    context,
                  )
                else if (provider.isBudgetExceeded)
                  _buildExceededCard(
                    remaining,
                  )
                else
                  _buildRemainingCard(
                    remaining,
                  ),

                const SizedBox(height: 18),

                // STAT CARDS
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Budget',
                        value:
                            '₹${budget.toStringAsFixed(0)}',
                        icon:
                            Icons.account_balance_wallet_outlined,
                        iconColor: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        title: 'Spent',
                        value:
                            '₹${spent.toStringAsFixed(0)}',
                        icon:
                            Icons.trending_down_outlined,
                        iconColor: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Remaining',
                        value: remaining >= 0
                            ? '₹${remaining.toStringAsFixed(0)}'
                            : '-₹${remaining.abs().toStringAsFixed(0)}',
                        icon:
                            Icons.savings_outlined,
                        iconColor: remaining >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        title: 'Used',
                        value:
                            '${(provider.budgetPercentage * 100).toStringAsFixed(1)}%',
                        icon:
                            Icons.pie_chart_outline,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ACTIONS
                const Text(
                  'Budget Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _buildActionButton(
                  context: context,
                  title: budget > 0
                      ? 'Edit Monthly Budget'
                      : 'Set Monthly Budget',
                  subtitle: budget > 0
                      ? 'Change your current budget'
                      : 'Create a spending limit',
                  icon: Icons.edit_outlined,
                  onTap: () {
                    _showBudgetDialog(
                      context,
                      provider,
                    );
                  },
                ),

                if (budget > 0) ...[
                  const SizedBox(height: 10),

                  _buildActionButton(
                    context: context,
                    title: 'Remove Budget',
                    subtitle:
                        'Clear your current monthly budget',
                    icon: Icons.delete_outline,
                    onTap: () {
                      _showDeleteBudgetDialog(
                        context,
                        provider,
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),

                // TIP
                _buildTipCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // NO BUDGET CARD
  // ------------------------------------------------------------

  Widget _buildNoBudgetCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.orange.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.orange,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'You have not set a monthly budget yet.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMAINING CARD
  // ------------------------------------------------------------

  Widget _buildRemainingCard(
    double remaining,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.green.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.green,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget Remaining',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '₹${remaining.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
  // EXCEEDED CARD
  // ------------------------------------------------------------

  Widget _buildExceededCard(
    double remaining,
  ) {
    final exceededAmount = remaining.abs();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget Exceeded',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'You are ₹${exceededAmount.toStringAsFixed(2)} over your budget.',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
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
  // STAT CARD
  // ------------------------------------------------------------

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),

          const Spacer(),

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTION BUTTON
  // ------------------------------------------------------------

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 21,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUDGET DIALOG
  // ------------------------------------------------------------

  void _showBudgetDialog(
    BuildContext context,
    ExpenseProvider provider,
  ) {
    final controller = TextEditingController(
      text: provider.monthlyBudget > 0
          ? provider.monthlyBudget
              .toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Set Monthly Budget',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Budget Amount',
              hintText: 'Example: 20000',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                  controller.text.trim(),
                );

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid budget amount.',
                      ),
                    ),
                  );
                  return;
                }

                await provider.setMonthlyBudget(
                  amount,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Monthly budget updated successfully.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DELETE BUDGET DIALOG
  // ------------------------------------------------------------

  void _showDeleteBudgetDialog(
    BuildContext context,
    ExpenseProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Budget?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Your monthly budget will be cleared. '
            'Your expenses will not be deleted.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                await provider.clearBudget();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Budget removed.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TIP CARD
  // ------------------------------------------------------------

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.amber,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Set a realistic monthly limit and check '
                  'your spending regularly to avoid overspending.',
                  style: TextStyle(
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
}