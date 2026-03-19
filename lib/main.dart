import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:flutter/foundation.dart';
import 'screens/income_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/savings_screen.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    /// Try changing this and hot reloading the application.
    ///
    /// To create a custom theme:
    /// ```shell
    /// dart forui theme create [theme template].
    /// ```
    final theme = FThemes.zinc.dark;

    return MaterialApp(
      // TODO: replace with your application's supported locales.
      supportedLocales: FLocalizations.supportedLocales,
      // TODO: add your application's localizations delegates.
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      // MaterialApp's theme is also animated by default with the same duration and curve.
      // See https://api.flutter.dev/flutter/material/MaterialApp/themeAnimationStyle.html for how to configure this.
      //
      // There is a known issue with implicitly animated widgets where their transition occurs AFTER the theme's.
      // See https://github.com/duobaseio/forui/issues/670.
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
      // You can also replace FScaffold with Material Scaffold.
      home: const FScaffold(
        // TODO: replace with your widget.
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  List<Widget> get _screens => <Widget>[
    IncomeScreen(navIndexNotifier: _selectedIndexNotifier),
    ExpensesScreen(navIndexNotifier: _selectedIndexNotifier),
    SavingsScreen(navIndexNotifier: _selectedIndexNotifier),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: FBottomNavigationBar(
        index: _selectedIndex,
        onChange: (index) => setState(() => _selectedIndex = index),
        children: [
          FBottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: Text('Income'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: Text('Expenses'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: Text('Savings'),
          ),
        ],
      ),
    );
  }
}
