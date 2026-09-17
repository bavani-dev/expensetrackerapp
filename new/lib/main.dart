import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';

import 'screens/home/home_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/income/income_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/profile/profile_screen.dart';

import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(),
        ),

        ChangeNotifierProvider<IncomeProvider>(
          create: (_) => IncomeProvider(),
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Expense Tracker',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20A4F3),
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF6F8FB),

        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color(0xFFF6F8FB),
          foregroundColor:
              Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(
              Radius.circular(18),
            ),
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF20A4F3),
            foregroundColor:
                Colors.white,
            elevation: 0,
            minimumSize:
                const Size(
              double.infinity,
              52,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide:
                BorderSide(
              color:
                  Color(0xFF20A4F3),
              width: 1.5,
            ),
          ),
        ),
      ),

      // IMPORTANT:
      // Open MainScreen instead of HomeScreen directly.
      home: const MainScreen(),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {

  int selectedIndex = 0;

  // ==========================================================
  // ALL APP MODULES
  // ==========================================================

  final List<Widget> screens = const [
    HomeScreen(),
    ExpensesScreen(),
    IncomeScreen(),
    BudgetScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Current module
      body: screens[selectedIndex],

      // ======================================================
      // BOTTOM NAVIGATION
      // ======================================================

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            selectedIndex,

        backgroundColor:
            Colors.white,

        indicatorColor:
            const Color(0xFF20A4F3)
                .withValues(
          alpha: 0.15,
        ),

        elevation: 3,

        onDestinationSelected:
            (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [

          // ==================================================
          // HOME
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),

            selectedIcon: Icon(
              Icons.home,
            ),

            label: 'Home',
          ),

          // ==================================================
          // EXPENSES
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),

            selectedIcon: Icon(
              Icons.receipt_long,
            ),

            label: 'Expenses',
          ),

          // ==================================================
          // INCOME
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),

            selectedIcon: Icon(
              Icons.account_balance_wallet,
            ),

            label: 'Income',
          ),

          // ==================================================
          // BUDGET
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.pie_chart_outline,
            ),

            selectedIcon: Icon(
              Icons.pie_chart,
            ),

            label: 'Budget',
          ),

          // ==================================================
          // PROFILE
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),

            selectedIcon: Icon(
              Icons.person,
            ),

            label: 'Profile',
          ),
        ],
      ),
    );
  }
}