// ignore_for_file: implementation_imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZE NOTIFICATIONS
  // ============================================================

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'expense_tracker_notifications',
      'Expense Tracker Notifications',
      channelDescription:
          'Notifications for your Expense Tracker app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: 1,
      title: 'Expense Tracker',
      body: 'Notification is working successfully! 🔔',
      notificationDetails: notificationDetails,
    );
  }

  // ============================================================
  // DAILY EXPENSE REMINDER
  // ============================================================

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelDailyReminder();

    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate =
          scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_expense_reminder',
      'Daily Expense Reminder',
      channelDescription:
          'Reminder to record your daily expenses',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id: 100,
      title: 'Expense Reminder',
      body: 'Don\'t forget to record today\'s expenses 💰',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );
  }

  // ============================================================
  // CANCEL DAILY REMINDER
  // ============================================================

  static Future<void> cancelDailyReminder() async {
    await _notifications.cancelAll();
  }

  // ============================================================
  // BUDGET WARNING
  // ============================================================

  static Future<void> showBudgetWarning({
    required double spent,
    required double budget,
  }) async {
    if (budget <= 0) {
      return;
    }

    final double percentage =
        (spent / budget) * 100;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budget_notifications',
      'Budget Notifications',
      channelDescription:
          'Notifications about your monthly budget',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    if (spent >= budget) {
      await _notifications.show(
        id: 200,
        title: 'Budget Exceeded 🚨',
        body: 'You have exceeded your monthly budget.',
        notificationDetails: notificationDetails,
      );
    } else if (percentage >= 80) {
      await _notifications.show(
        id: 201,
        title: 'Budget Warning ⚠️',
        body: 'You have used ${percentage.toStringAsFixed(0)}% of your budget.',
        notificationDetails: notificationDetails,
      );
    }
  }
}
