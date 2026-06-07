import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:my_money/l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as model;
import 'package:graphic/graphic.dart';

//Buttons to select time range for graphs
enum TimeRange { month, year }

class IncomeEntry {
  final DateTime date;
  final double amount; // Amount
  final String category; // "Salary", "Freelance", etc.
  final Color color; // Category color

  IncomeEntry({
    required this.date,
    required this.amount,
    required this.category,
    required this.color,
  });
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _db = DatabaseService();
  List<model.Transaction> _income = [];
  List<Map<String, Color>> _categories = [];
  bool _isLoading = true;
  TimeRange _range = TimeRange.month;
  double _usdRate = 42.0;
  double _eurRate = 51.0;

  // methods for the current view
  DateTime _selectedDate = DateTime.now();
  String _getDate() {
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (_range == TimeRange.month) {
      return DateFormat('LLLL yyyy', locale).format(_selectedDate);
    } else {
      return DateFormat('yyyy', locale).format(_selectedDate);
    }
  }

  void _nextDate() {
    if (_range == TimeRange.month) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    } else if (_range == TimeRange.year) {
      _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month);
    }
    setState(() {});
  }

  void _previousDate() {
    if (_range == TimeRange.month) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    } else if (_range == TimeRange.year) {
      _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month);
    }
    setState(() {});
  }

  String _getTotal(currency) {
    double total = 0;
    for (final tx in _income) {
      if (_range == TimeRange.month) {
        if (tx.date.year == _selectedDate.year &&
            tx.date.month == _selectedDate.month) {
          currency == 'UAH' ? total += _toUAH(tx) : total += tx.amount_usd;
        }
      } else {
        if (tx.date.year == _selectedDate.year) {
          // total += _toUAH(tx);
          currency == 'UAH' ? total += _toUAH(tx) : total += tx.amount_usd;
        }
      }
    }

    var formatter = NumberFormat('#,##,000');
    String numberTotal = formatter.format(total).trim().replaceAll(',', ' ');
    return '$numberTotal '
        '$currency';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tx = await _db.getTransactions('income');
      final rates = await _db.getExchangeRates();
      final categories = await _db.getSources('income');
      setState(() {
        _income = tx;
        _categories = categories
            .map(
              (c) => {
                c['name'] as String: Color(
                  int.parse(c['color'] as String, radix: 16),
                ),
              },
            )
            .toList();
        _usdRate = rates['usd'] ?? _usdRate;
        _eurRate = rates['eur'] ?? _eurRate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading income: $e')));
    }
  }

  // Set the time range for graphs and refresh the data
  void _setRange(TimeRange r) {
    setState(() {
      _range = r;
    });
  }

  double _toUAH(model.Transaction tx) {
    return tx.amount;
  }

  // Returns list of (type, date, value, value) pairs ordered by time
  // {"type": "Income", "index": 0, "value": 1000}
  Map<String, IncomeEntry> _aggregate() {
    if (_range == TimeRange.month) {
      // get the numbers of days to display based on current month
      final daysInMonth = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        0,
      ).day; // Gets last day number

      // last 30 days grouped by day
      final days = List.generate(
        daysInMonth,
        (i) => DateTime(_selectedDate.year, _selectedDate.month, i + 1),
      );

      final map = <String, IncomeEntry>{};
      // go through all days
      for (final d in days) {
        map[DateFormat('yyyy-MM-dd').format(d)] = IncomeEntry(
          date: d,
          amount: 0.0,
          category: '',
          color: Colors.transparent,
        );
      }

      // go through all income
      for (final tx in _income) {
        final key = DateFormat('yyyy-MM-dd').format(tx.date);

        if (map.containsKey(key)) {
          map[key] = IncomeEntry(
            date: map[key]!.date,
            amount: map[key]!.amount + _toUAH(tx),
            category: map[key]!.category,
            color: Colors.white,
          );
        }
      }
      return map;
    } else if (_range == TimeRange.year) {
      // Current year months grouped by month
      final months = List.generate(
        12,
        (i) => DateTime(_selectedDate.year, i + 1, 1),
      );
      final map = <String, IncomeEntry>{};
      for (final m in months) {
        map[DateFormat('yyyy-MM').format(m)] = IncomeEntry(
          date: m,
          amount: 0.0,
          category: '',
          color: Colors.transparent,
        );
      }
      for (final tx in _income) {
        if (tx.date.year == _selectedDate.year) {
          final key = DateFormat('yyyy-MM').format(tx.date);

          if (map.containsKey(key)) {
            map[key] = IncomeEntry(
              date: map[key]!.date,
              amount: map[key]!.amount + _toUAH(tx),
              category: map[key]!.category,
              color: Colors.white,
            );
          }
        }
      }
      return map;
    } else {
      // All time grouped by year
      final map = <String, IncomeEntry>{};
      for (final tx in _income) {
        final key = tx.date.year.toString();
        map[key] =
            (map[key] ??
            IncomeEntry(
              date: DateTime.parse(key),
              amount: 0.0,
              category: '',
              color: Colors.transparent,
            ));
      }
      return map;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _aggregate().entries
        .map((e) => MapEntry(e.key, e.value.amount))
        .toList();

    double maxY = data.isEmpty
        ? 0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final l10n = AppLocalizations.of(context)!;
    final theme = FTheme.of(context);
    final theme_colors = theme.colors;

    final graphData = data.asMap().entries.map((entry) {
      return {'type': 'Income', 'index': entry.key, 'value': entry.value.value};
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      // TODO: add total Tithes calculation
      // TODO: filter by category
      // TODO: add graph/pie chart for income categories
      //
      //Buttons
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month/Year selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.month),
                        selected: _range == TimeRange.month,
                        onSelected: (_) => _setRange(TimeRange.month),
                      ),
                      ChoiceChip(
                        label: Text(l10n.year),
                        selected: _range == TimeRange.year,
                        onSelected: (_) => _setRange(TimeRange.year),
                      ),
                    ],
                  ),
                  // Date selector with arrows left and right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        iconSize: 48.0,
                        tooltip: 'Previous Date',
                        onPressed: _previousDate,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _getDate(),
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        iconSize: 48.0,
                        tooltip: 'Next Date',
                        onPressed: _nextDate,
                      ),
                    ],
                  ),

                  Text(
                    '${l10n.total_income}: ${_getTotal('UAH')} (${_getTotal('USD')})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 350,
                    height: 300,
                    child: Chart(
                      data: graphData,
                      variables: {
                        'index': Variable(
                          accessor: (Map map) => map['index'].toString(),
                        ),
                        'type': Variable(
                          accessor: (Map map) => map['type'] as String,
                        ),
                        'value': Variable(
                          accessor: (Map map) => (map['value'] as num).toInt(),
                          scale: LinearScale(min: 0, max: maxY * 1.2),
                        ),
                      },
                      marks: [
                        IntervalMark(
                          position:
                              Varset('index') *
                              Varset('value') /
                              Varset('type'),
                          shape: ShapeEncode(
                            value: RectShape(labelPosition: 1),
                          ),
                          color: ColorEncode(
                            variable: 'type',
                            values: Defaults.colors10,
                          ),
                          label: LabelEncode(
                            encoder: (tuple) => Label(
                              tuple['value'].toString(),
                              LabelStyle(
                                textStyle: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          modifiers: [StackModifier()],
                        ),
                      ],
                      coord: RectCoord(
                        horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                      ),
                      axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
                      selections: {'tap': PointSelection(variable: 'index')},
                      tooltip: TooltipGuide(multiTuples: true),
                      // crosshair: CrosshairGuide(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
