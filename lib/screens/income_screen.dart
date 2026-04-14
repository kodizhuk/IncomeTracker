import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';

import 'package:forui/forui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class IncomeScreen extends StatefulWidget {
  final ValueNotifier<int>? navIndexNotifier;
  const IncomeScreen({super.key, this.navIndexNotifier});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Transaction> _incomeTransactions = [];
  List<Transaction> _allIncomeTransactions = [];
  List<Transaction> _expenseTransactions = [];
  bool _isLoading = true;
  double _settingsUsdRate = 42.0;
  double _settingsEurRate = 51.0;
  bool _showAllTime = false;

  final List<String> incomeCategoriesDefault = [
    'Salary',
    'Freelance',
    'Investments',
  ];

  // methods for the current view
  DateTime _selectedDate = DateTime.now();
  String _getDate() {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return _showAllTime
        ? 'All Time'
        : DateFormat('LLLL yyyy', locale).format(_selectedDate);
  }

  void _nextDate() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    _loadTransactions(); // Reload transactions for the new month
    setState(() {});
  }

  void _previousDate() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    _loadTransactions(); // Reload transactions for the new month
    setState(() {});
  }

  String _getTotal() {
    double total = 0;
    // for (final tx in _income) {
    //   if (tx.date.year == _selectedDate.year && tx.date.month == _selectedDate.month) {
    //     total += _toUAH(tx);
    //   }
    // }

    var formatter = NumberFormat('#,##,000');
    String numberTotal = formatter.format(total).trim().replaceAll(',', ' ');
    return total > 0 ? '$numberTotal UAH' : '0 UAH';
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    widget.navIndexNotifier?.addListener(_onNavIndexChanged);
  }

  void _onNavIndexChanged() {
    if (widget.navIndexNotifier?.value == 0) {
      _loadTransactions();
    }
  }

  @override
  void dispose() {
    widget.navIndexNotifier?.removeListener(_onNavIndexChanged);
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _dbService.getTransactions('income');
      final expenses = await _dbService.getTransactions('expense');
      final rates = await _dbService.getExchangeRates();
      setState(() {
        //filter transactions for the selected month or show all
        if (_showAllTime) {
          _incomeTransactions = transactions;
        } else {
          _incomeTransactions = transactions.where((tx) {
            return tx.date.year == _selectedDate.year &&
                tx.date.month == _selectedDate.month;
          }).toList();
        }
        _allIncomeTransactions = transactions;
        _expenseTransactions = expenses;
        _settingsUsdRate = rates['usd'] ?? _settingsUsdRate;
        _settingsEurRate = rates['eur'] ?? _settingsEurRate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading transactions: $e')));
    }
  }

  void _addTransaction() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          type: 'income',
          defaultCategories: incomeCategoriesDefault,
        ),
      ),
    );

    if (result != null) {
      try {
        await _dbService.insertTransaction(result);
        _loadTransactions(); // Reload to get the updated list with IDs
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    }
  }

  void _deleteTransaction(int index) async {
    final transaction = _incomeTransactions[index];
    if (transaction.id != null) {
      try {
        await _dbService.deleteTransaction(transaction.id!);
        _loadTransactions(); // Reload to get the updated list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting transaction: $e')),
        );
      }
    }
  }

  void _editTransaction(int index) async {
    final transaction = _incomeTransactions[index];
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          type: 'income',
          defaultCategories: incomeCategoriesDefault,
          existingTransaction: transaction,
        ),
      ),
    );

    if (result != null) {
      try {
        await _dbService.updateTransaction(result);
        _loadTransactions(); // Reload to get the updated list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction: $e')),
        );
      }
    }
  }

  double get _totalIncome {
    return _incomeTransactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  String _formatTotal() {
    String symbol = '₴';
    if (_incomeTransactions.isNotEmpty) {
      switch (_incomeTransactions.first.currency) {
        case 'USD':
          symbol = r'$';
          break;
        case 'EUR':
          symbol = '€';
          break;
        case 'UAH':
        default:
          symbol = '₴';
      }
    }
    return 'Total Income: $symbol${_totalIncome.toStringAsFixed(2)}';
  }

  String _calculateTithe() {
    // Convert all income to UAH

    double totalIncomeUAH = _allIncomeTransactions.fold(0.0, (sum, tx) {
      if (tx.currency == 'UAH') {
        return sum = sum + tx.amount;
      }
      return sum;
    });

    // Sum expenses whose source/category equals 'Tithes' (case-insensitive), in UAH
    double titheExpensesUAH = _expenseTransactions.fold(0.0, (sum, tx) {
      if ((tx.source ?? '').toString().toLowerCase() != 'tithes') return sum;

      if (tx.currency == 'UAH') {
        return sum = sum + tx.amount;
      }
      return sum;
    });

    final titheUAH = totalIncomeUAH * 0.1;
    final resultUAH = titheUAH - titheExpensesUAH;
    return '₴${resultUAH.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FButton(
                          onPress: _showAllTime ? null : _previousDate,
                          style: FButtonStyle.ghost(),
                          child: const Icon(FIcons.chevronLeft),
                        ),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAllTime = !_showAllTime;
                              _loadTransactions();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              _getDate(),
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        FButton(
                          onPress: _showAllTime ? null : _nextDate,
                          style: FButtonStyle.ghost(),
                          child: const Icon(FIcons.chevronRight),
                        ),
                      ],
                    ),
                  ),
                  _incomeTransactions.isEmpty
                      ? Text(
                          'No income transactions yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _incomeTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionItem(
                                transaction: _incomeTransactions[index],
                                onDelete: () => _deleteTransaction(index),
                                onEdit: () => _editTransaction(index),
                              );
                            },
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
