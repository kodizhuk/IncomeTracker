import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_money/screens/settings_screen.dart';
import 'package:my_money/screens/statistics_screen.dart';
import 'l10n/app_localizations.dart';

import 'screens/in_out_screen.dart';
import 'screens/savings_screen.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FThemes.blue.dark;

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('uk'), // Set to Ukrainian
      // localizationsDelegates: const [
      //   FLocalizations.delegate, // Add this line
      // ],
      // supportedLocales: const [
      //   Locale('en'), // English
      //   Locale('uk'), // Ukranian
      // ],
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),

      home: FScaffold(child: AppStates()),
    );
  }
}

class AppStates extends StatefulWidget {
  @override
  State<AppStates> createState() => _AppStates();
}

class _AppStates extends State<AppStates> {
  final _contents = [
    const Column(
      mainAxisAlignment: .center,
      children: [Text('Income Placeholder')],
    ),
    const Column(
      mainAxisAlignment: .center,
      children: [Text('Expenses Placeholder')],
    ),
    const Column(
      mainAxisAlignment: .center,
      children: [Text('Savings Placeholder')],
    ),
  ];

  int _selectedIndex = 0;
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  List<Widget> get _screens => <Widget>[
    InOutScreen(navIndexNotifier: _selectedIndexNotifier, type: 'income'),
    InOutScreen(navIndexNotifier: _selectedIndexNotifier, type: 'expenses'),
    SavingsScreen(navIndexNotifier: _selectedIndexNotifier),
  ];

  FHeader _buildHeader(BuildContext context, String title) {
    return FHeader(
      title: Text(title),
      suffixes: [
        FHeaderAction(
          icon: const Icon(FIcons.chartColumn),
          onPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatisticsScreen()),
            );
          },
        ),
        const SizedBox(width: 6),
        FHeaderAction(
          icon: const Icon(FIcons.settings),
          onPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final headers = [
      _buildHeader(context, l10n.income),
      _buildHeader(context, l10n.expenses),
      _buildHeader(context, l10n.savings),
    ];

    return SizedBox(
      height: 500,
      child: FScaffold(
        header: headers[_selectedIndex],
        footer: FBottomNavigationBar(
          index: _selectedIndex,
          onChange: (index) => setState(() => _selectedIndex = index),
          children: [
            FBottomNavigationBarItem(
              icon: Icon(FIcons.trendingUp),
              label: Text(l10n.income),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.trendingDown),
              label: Text(l10n.expenses),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.wallet),
              label: Text(l10n.savings),
            ),
          ],
        ),
        child: _screens[_selectedIndex],
        // child: _contents[_selectedIndex],
      ),
    );
  }
}
