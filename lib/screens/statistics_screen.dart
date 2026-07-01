import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:my_money/l10n/app_localizations.dart';
import 'package:my_money/services/exchange_rates.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as model;
import 'package:graphic/graphic.dart';

//Buttons to select time range for graphs
enum TimeRange { month, year }

class LegendItem {
  final String label;
  final Color color;
  final double total;

  LegendItem({required this.label, required this.color, required this.total});
}

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
  // chart state
  List<Map<String, Object>> _graphData = [];
  List<Map<String, Object>> _pieData = [];
  double _maxYState = 1;

  DateTime _selectedDate = DateTime.now();

  //List of sources for the dropdown
  final FSelectController<String> _sourcesController =
      FSelectController<String>();
  List<String> _sourcesList = ['Income', 'Expense'];
  //List of categories for the dropdown
  final FSelectController<String> _categoriesController =
      FSelectController<String>();
  List <String> _categoriesList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      // final l10n = AppLocalizations.of(context)!;
      final incomeList = await DatabaseService().getSources('income');
      final expencesList = await DatabaseService().getSources('expense');

      //initl the dropdown with the first source
      _sourcesController.value = _sourcesList.first;
      if (incomeList.isNotEmpty) {
        _categoriesList = incomeList.map((r) => r['name'].toString()).toList();
        _categoriesController.value = incomeList.first['name'] as String;
      } else{
        _categoriesController.value = 'None';
      }

      _sourcesController.addListener(() {
        // update _categoriesList whenever the _sourcesController changes
        setState(() {
          if (_sourcesController.value == 'Income'){
            _categoriesList = incomeList.map((r) => r['name'].toString()).toList();
            _categoriesController.value = incomeList.isNotEmpty ? incomeList.first['name'] as String : 'None';
          } else if (_sourcesController.value == 'Expense'){
            _categoriesList = expencesList.map((r) => r['name'].toString()).toList();
            _categoriesController.value = expencesList.isNotEmpty ? expencesList.first['name'] as String : 'None';
          }
        });
      });
    } catch (e) {
      setState(() {
      });
    }
  }

  String _getDate() {
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (_range == TimeRange.month) {
      return DateFormat('LLLL yyyy', locale).format(_selectedDate);
    } else {
      return DateFormat('yyyy', locale).format(_selectedDate);
    }
  }

  String _getTotal() {
    double total = 0;
    for (final tx in _income) {
      if (_range == TimeRange.month) {
        if (tx.date.year == _selectedDate.year &&
            tx.date.month == _selectedDate.month) {
          total += tx.amount_usd;
        }
      } else {
        if (tx.date.year == _selectedDate.year) total += tx.amount_usd;
      }
    }

    var formatter = NumberFormat('###,###');
    String numberTotal = formatter.format(total).trim().replaceAll(',', ' ');
    return '$numberTotal '
        r'$';
  }

  void _nextDate() {
    if (_range == TimeRange.month) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    } else if (_range == TimeRange.year) {
      _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month);
    }
    setState(() {
      _recomputeCharts();
    });
  }

  void _previousDate() {
    if (_range == TimeRange.month) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    } else if (_range == TimeRange.year) {
      _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month);
    }
    setState(() {
      _recomputeCharts();
    });
  }

  Future<void> _loadData() async {
    final rates = Provider.of<ExchangeRates>(context, listen: false);
    var usdRate = rates.usd;
    var eurRate = rates.eur;
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
        usdRate = rates['usd'] ?? usdRate;
        eurRate = rates['eur'] ?? eurRate;
        _isLoading = false;
      });
      _recomputeCharts();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading income: $e')));
    }
  }

  void _recomputeCharts() {
    // build source color map
    _maxYState = 1;
    final list = <String, Color>{};
    for (final m in _categories) {
      if (m.isNotEmpty) {
        final name = m.keys.first;
        final color = m.values.first;
        list[name] = color;
      }
    }

    // labels for current range
    final labels = _aggregate().keys.toList();

    final graphData = <Map<String, Object>>[];
    if (list.isNotEmpty) {
      for (final source in list.keys) {
        for (var i = 0; i < labels.length; i++) {
          final label = labels[i];
          double sum = 0;
          for (final tx in _income) {
            if ((tx.source ?? '') == source) {
              final txLabel = _range == TimeRange.month
                  ? DateFormat('yyyy-MM-dd').format(tx.date)
                  : _range == TimeRange.year
                  ? DateFormat('yyyy-MM').format(tx.date)
                  : tx.date.year.toString();
              if (txLabel == label) sum += tx.amount_usd;
            }
          }
          // if (sum > _maxYState) _maxYState = sum;
          graphData.add({'type': source, 'index': i, 'value': sum});
        }
      }
    } else {
      final data = _aggregate().entries
          .map((e) => MapEntry(e.key, e.value.amount))
          .toList();
      graphData.addAll(
        data.asMap().entries.map((entry) {
          return {
            'type': 'Income',
            'index': entry.key,
            'value': entry.value.value,
          };
        }),
      );
    }

    final Map<String, double> pieMap = {};
    for (final entry in graphData) {
      final t = entry['type'] as String;
      final v = (entry['value'] as num).toDouble();
      if (v == 0) continue;
      pieMap[t] = (pieMap[t] ?? 0) + v;
    }

    final pieData = pieMap.entries
        .map((e) => {'type': e.key, 'value': e.value})
        .toList();

    final dataVals = graphData
        .map((e) => (e['value'] as num).toDouble())
        .toList();
    double maxY = dataVals.isEmpty
        ? 1
        : dataVals.reduce((a, b) => a > b ? a : b);

    setState(() {
      _graphData = graphData;
      _pieData = pieData;
      _maxYState = maxY;
    });
  }

  // Set the time range for graphs and refresh the data
  void _setRange(TimeRange r) {
    setState(() {
      _range = r;
      _recomputeCharts();
    });
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
            amount: map[key]!.amount + tx.amount_usd,
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
              amount: map[key]!.amount + tx.amount_usd,
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
    final rates = Provider.of<ExchangeRates>(context, listen: false);
    final usdRate = rates.usd;
    final eurRate = rates.eur;

    // use precomputed chart state
    final graphData = _graphData;
    final pieData = _pieData;

    final l10n = AppLocalizations.of(context)!;
    final theme = FTheme.of(context);
    final themeColors = theme.colors;

    // Build legend items from pieData
    // final legendItems = pieData.map((e) {
    final legendItems = pieData.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;

      final label = e['type'] as String;
      final total = (e['value'] as num).toDouble();
      final color = Defaults.colors10[index];
      return LegendItem(label: label, color: color, total: total);
    }).toList();

    final colorByType = {
      for (final item in legendItems) item.label: item.color,
    };

    // graphData/pieData/maxY are provided from state (recomputed)

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      // TODO: add total Tithes calculation
      // TODO: filter by category

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
                      Expanded(
                        child: FSelect<String>.rich(
                          control: .managed(controller: _sourcesController),
                          format: (s) => s,
                          children: [
                            for (final source in _sourcesList)
                              .item(title: Text(source), value: source),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FSelect<String>.rich(
                          control: .managed(controller: _categoriesController),
                          format: (s) => s,
                          children: [
                            for (final category in _categoriesList)
                              .item(title: Text(category), value: category),
                          ],
                        ),
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
                    '${l10n.total_income}: ${_getTotal()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Legend
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Text(
                              '${item.label}: ${item.total} \$',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // Graphs
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children:  [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 350,
                            height: 300,
                            child:
                                (graphData.isEmpty ||
                                    !graphData.any((e) => (e['value'] as num) > 0))
                                ? const Center(child: Text('No data'))
                                : Chart(
                                    key: ValueKey(
                                      graphData
                                          .map(
                                            (e) =>
                                                '${e['type']}:${e['index']}:${e['value']}',
                                          )
                                          .join('|'),
                                    ),
                                    data: graphData,
                                    variables: {
                                      'index': Variable(
                                        accessor: (Map map) => map['index'].toString(),
                                      ),
                                      'type': Variable(
                                        accessor: (Map map) => map['type'] as String,
                                      ),
                                      'value': Variable(
                                        accessor: (Map map) =>
                                            (map['value'] as num).toInt(),
                                        scale: LinearScale(min: 0, max: _maxYState * 2),
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
                                          encoder: (tuple) =>
                                              colorByType[tuple['type']] ?? Colors.grey,
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
                                    axes: [
                                      Defaults.horizontalAxis,
                                      Defaults.verticalAxis,
                                    ],
                                    // selections: {
                                    //   'tap': PointSelection(variable: 'value'),
                                    // },
                                    // tooltip: TooltipGuide(multiTuples: true),
                                    // crosshair: CrosshairGuide(),
                                  ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 350,
                            height: 300,
                            child: (pieData.isEmpty)
                                ? const Center(child: Text('No data'))
                                : Chart(
                                    key: ValueKey(
                                      pieData
                                          .map((e) => '${e['type']}:${e['value']}')
                                          .join('|'),
                                    ),
                                    data: pieData,
                                    variables: {
                                      'type': Variable(
                                        accessor: (Map map) => map['type'] as String,
                                      ),
                                      'value': Variable(
                                        accessor: (Map map) => map['value'] as num,
                                      ),
                                    },
                                    transforms: [
                                      Proportion(variable: 'value', as: 'percent'),
                                    ],
                                    marks: [
                                      IntervalMark(
                                        position: Varset('percent') / Varset('type'),
                                        label: LabelEncode(
                                          encoder: (tuple) =>
                                              Label(tuple['value'].toString()),
                                        ),
                                        color: ColorEncode(
                                          encoder: (tuple) =>
                                              colorByType[tuple['type']] ?? Colors.grey,
                                        ),
                                        modifiers: [StackModifier()],
                                      ),
                                    ],
                                    coord: PolarCoord(
                                      transposed: true,
                                      dimCount: 1,
                                      dimFill: 1.05,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
