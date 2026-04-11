import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:flutter/foundation.dart';
import 'screens/income_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/savings_screen.dart';

void main() {
  runApp(const Application());
}

// class Application extends StatelessWidget {
//   const Application({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final foruiTheme = FThemes.zinc.dark;
//     return MaterialApp(
//       theme: foruiTheme.toApproximateMaterialTheme(),
//       builder: (_, child) => FAnimatedTheme(data: foruiTheme, child: child!),
//       home: const HomePage(),
//     );
//   }
// }

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late FThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = FThemes.zinc.dark; // Start with your preferred default
  }

  void _setTheme(FThemeData newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _currentTheme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: _currentTheme, child: child!),
      home: HomePage(onThemeSelected: _setTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required void Function(FThemeData newTheme) onThemeSelected,
  });

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
    return FScaffold(
      child: _screens[_selectedIndex],
      footer: FBottomNavigationBar(
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
