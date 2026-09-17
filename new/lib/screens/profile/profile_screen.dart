// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  bool isEditing = false;

  // =========================
  // DAILY REMINDER SETTINGS
  // =========================

  bool dailyReminderEnabled = false;

  TimeOfDay reminderTime =
      const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();

    loadProfile();
    _loadReminderSettings();
  }

  // =========================
  // LOAD PROFILE
  // =========================

  Future<void> loadProfile() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    nameController.text =
        prefs.getString('profile_name') ?? '';

    emailController.text =
        prefs.getString('profile_email') ?? '';

    if (mounted) {
      setState(() {});
    }
  }

  // =========================
  // SAVE PROFILE
  // =========================

  Future<void> saveProfile() async {
    final String name =
        nameController.text.trim();

    final String email =
        emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
        ),
      );
      return;
    }

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'profile_name',
      name,
    );

    await prefs.setString(
      'profile_email',
      email,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile saved successfully',
        ),
      ),
    );
  }

  // =========================
  // LOAD REMINDER SETTINGS
  // =========================

  Future<void> _loadReminderSettings() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final bool enabled =
        prefs.getBool('daily_reminder_enabled') ?? false;

    final int hour =
        prefs.getInt('daily_reminder_hour') ?? 20;

    final int minute =
        prefs.getInt('daily_reminder_minute') ?? 0;

    if (!mounted) {
      return;
    }

    setState(() {
      dailyReminderEnabled = enabled;
      reminderTime = TimeOfDay(
        hour: hour,
        minute: minute,
      );
    });
  }

  // =========================
  // TOGGLE DAILY REMINDER
  // =========================

  Future<void> _toggleDailyReminder(
    bool value,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'daily_reminder_enabled',
      value,
    );

    if (!value) {
      await NotificationService.cancelDailyReminder();

      if (!mounted) {
        return;
      }

      setState(() {
        dailyReminderEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Daily reminder disabled',
          ),
        ),
      );

      return;
    }

    await NotificationService.scheduleDailyReminder(
      hour: reminderTime.hour,
      minute: reminderTime.minute,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      dailyReminderEnabled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Daily reminder enabled',
        ),
      ),
    );
  }

  // =========================
  // SELECT REMINDER TIME
  // =========================

  Future<void> _selectReminderTime() async {
    final TimeOfDay? selectedTime =
        await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );

    if (selectedTime == null) {
      return;
    }

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      'daily_reminder_hour',
      selectedTime.hour,
    );

    await prefs.setInt(
      'daily_reminder_minute',
      selectedTime.minute,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      reminderTime = selectedTime;
    });

    if (dailyReminderEnabled) {
      await NotificationService.scheduleDailyReminder(
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reminder time updated',
          ),
        ),
      );
    }
  }

  // =========================
  // REFRESH DATA
  // =========================

  Future<void> _refreshData() async {
    final ExpenseProvider expenseProvider =
        Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    final IncomeProvider incomeProvider =
        Provider.of<IncomeProvider>(
      context,
      listen: false,
    );

    await expenseProvider.loadExpenses();
    await incomeProvider.loadIncomes();
    await loadProfile();
    await _loadReminderSettings();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Data refreshed successfully',
        ),
      ),
    );
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor:
            const Color(0xFFF6F8FB),
        elevation: 0,
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF20A4F3),
              ),
            ),
        ],
      ),

      body: Consumer2<
          ExpenseProvider,
          IncomeProvider>(
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

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // =========================
                  // PROFILE CARD
                  // =========================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        // PROFILE ICON
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF20A4F3,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 48,
                            color:
                                Color(0xFF20A4F3),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // NAME
                        TextField(
                          controller:
                              nameController,
                          enabled: isEditing,
                          textAlign:
                              TextAlign.center,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Enter your name',
                            prefixIcon:
                                const Icon(
                              Icons.person_outline,
                              color:
                                  Color(0xFF20A4F3),
                            ),
                            filled: true,
                            fillColor:
                                const Color(
                              0xFFF6F8FB,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // EMAIL
                        TextField(
                          controller:
                              emailController,
                          enabled: isEditing,
                          keyboardType:
                              TextInputType
                                  .emailAddress,
                          textAlign:
                              TextAlign.center,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Enter your email',
                            prefixIcon:
                                const Icon(
                              Icons.email_outlined,
                              color:
                                  Color(0xFF20A4F3),
                            ),
                            filled: true,
                            fillColor:
                                const Color(
                              0xFFF6F8FB,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Colors.grey.shade700,
                          ),
                        ),

                        if (isEditing) ...[
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  saveProfile,
                              icon: const Icon(
                                Icons.save_outlined,
                              ),
                              label: const Text(
                                'Save Profile',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],

                        if (!isEditing &&
                            nameController
                                .text
                                .isEmpty &&
                            emailController
                                .text
                                .isEmpty) ...[
                          const SizedBox(height: 10),

                          Text(
                            'Tap the edit button to add your profile',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // NOTIFICATIONS
                  // =========================

                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
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
                              const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        // DAILY REMINDER
                        ListTile(
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color: const Color(
                                0xFF20A4F3,
                              ).withValues(
                                alpha: 0.1,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(12),
                            ),
                            child: const Icon(
                              Icons
                                  .notifications_outlined,
                              color:
                                  Color(0xFF20A4F3),
                            ),
                          ),
                          title: const Text(
                            'Daily Expense Reminder',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Remind me every day at ${reminderTime.format(context)}',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing:
                              Switch(
                            value:
                                dailyReminderEnabled,
                            onChanged:
                                _toggleDailyReminder,
                          ),
                        ),

                        const Divider(
                          height: 1,
                        ),

                        // REMINDER TIME
                        ListTile(
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color: const Color(
                                0xFF20A4F3,
                              ).withValues(
                                alpha: 0.1,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(12),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color:
                                  Color(0xFF20A4F3),
                            ),
                          ),
                          title: const Text(
                            'Reminder Time',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            reminderTime.format(
                              context,
                            ),
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing:
                              const Icon(
                            Icons
                                .chevron_right,
                            color: Colors.grey,
                          ),
                          onTap:
                              _selectReminderTime,
                        ),
                          const Divider(
                          height: 1,
                        ),

                        // TEST NOTIFICATION
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF20A4F3).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: Color(0xFF20A4F3),
                            ),
                          ),
                          title: const Text(
                            'Test Notification',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Send a test notification',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () async {
                            try {
                              await NotificationService.showTestNotification();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Test notification sent 🔔')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Notification failed: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // FINANCIAL SUMMARY
                  // =========================

                  const Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      Expanded(
                        child:
                            _buildSummaryCard(
                          title: 'Income',
                          amount:
                              totalIncome,
                          icon: Icons
                              .arrow_downward_rounded,
                          color:
                              const Color(
                            0xFF22B573,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child:
                            _buildSummaryCard(
                          title: 'Expenses',
                          amount:
                              totalExpenses,
                          icon: Icons
                              .arrow_upward_rounded,
                          color:
                              const Color(
                            0xFFE74C3C,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSummaryCard(
                    title: 'Current Balance',
                    amount: balance,
                    icon: Icons
                        .account_balance_wallet_outlined,
                    color:
                        const Color(0xFF20A4F3),
                    fullWidth: true,
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // TRANSACTIONS
                  // =========================

                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      Expanded(
                        child:
                            _buildCountCard(
                          title: 'Income',
                          count: incomeProvider
                              .incomes.length,
                          icon:
                              Icons.trending_up,
                          color:
                              const Color(
                            0xFF22B573,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child:
                            _buildCountCard(
                          title: 'Expenses',
                          count:
                              expenseProvider
                                  .expenses
                                  .length,
                          icon:
                              Icons.trending_down,
                          color:
                              const Color(
                            0xFFE74C3C,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // APP INFORMATION
                  // =========================

                  const Text(
                    'App Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [

                        _buildInfoTile(
                          icon: Icons
                              .account_balance_wallet_outlined,
                          title: 'Application',
                          value:
                              'Expense Tracker',
                        ),

                        const Divider(
                          height: 1,
                        ),

                        _buildInfoTile(
                          icon:
                              Icons.currency_rupee,
                          title: 'Currency',
                          value:
                              'Indian Rupee (₹)',
                        ),

                        const Divider(
                          height: 1,
                        ),

                        _buildInfoTile(
                          icon:
                              Icons.storage_outlined,
                          title: 'Data Storage',
                          value:
                              'Local device',
                        ),

                        const Divider(
                          height: 1,
                        ),

                        _buildInfoTile(
                          icon:
                              Icons.info_outline,
                          title: 'Version',
                          value: '1.0.0',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =========================
                  // REFRESH BUTTON
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          _refreshData,
                      icon: const Icon(
                        Icons.refresh,
                        color:
                            Color(0xFF20A4F3),
                      ),
                      label: const Text(
                        'Refresh Data',
                        style: TextStyle(
                          color:
                              Color(0xFF20A4F3),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Expense Tracker v1.0.0',
                      style: TextStyle(
                        color:
                            Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // SUMMARY CARD
  // =========================

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth
          ? double.infinity
          : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.1,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // COUNT CARD
  // =========================

  Widget _buildCountCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              color: color.withValues(
                alpha: 0.1,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '$count',
            style: const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '$title transactions',
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INFO TILE
  // =========================

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: Row(
        children: [

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(
                0xFF20A4F3,
              ).withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFF20A4F3),
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
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
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