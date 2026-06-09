import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_money/services/exchange_rates.dart';
import 'package:provider/provider.dart';
import '../models/savings_account.dart';
import '../services/database_service.dart';
import 'add_savings_screen.dart';
import '../widgets/savings_account_widget.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import '../l10n/app_localizations.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SavingsScreen extends StatefulWidget {
  final ValueNotifier<int>? navIndexNotifier;
  const SavingsScreen({super.key, this.navIndexNotifier});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final List<SavingsAccount> _savingsAccounts = [];

  bool _isLoading = true;
  String _selectedCurrency = 'All';
  String _ratesText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadSavingsAccounts();
    // _loadRates();
    widget.navIndexNotifier?.addListener(_onNavIndexChanged);
  }

  void _onNavIndexChanged() {
    if (widget.navIndexNotifier?.value == 2) {
      _loadSavingsAccounts();
    }
  }

  @override
  void dispose() {
    widget.navIndexNotifier?.removeListener(_onNavIndexChanged);
    super.dispose();
  }

  Future<void> _loadSavingsAccounts() async {
    setState(() => _isLoading = true);
    try {
      final savingsAccounts = await _dbService.getSavingsAccounts();
      final rates = await _dbService.getExchangeRates();
      _savingsAccounts.clear();
      setState(() {
        for (final acc in savingsAccounts) {
          if (acc.currency == 'UAH' && _selectedCurrency == 'UAH') {
            _savingsAccounts.add(acc);
          } else if (acc.currency == 'USD' && _selectedCurrency == 'USD') {
            _savingsAccounts.add(acc);
          } else if (acc.currency == 'EUR' && _selectedCurrency == 'EUR') {
            _savingsAccounts.add(acc);
          } else if (_selectedCurrency == 'All') {
            _savingsAccounts.add(acc);
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading savings accounts: $e')),
      );
    }
  }

  void _addSavingsAccount() async {
    final result = await Navigator.push<SavingsAccount>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditSavingsAccountScreen(),
      ),
    );

    if (result != null) {
      try {
        await _dbService.insertSavingsAccount(result);
        _loadSavingsAccounts(); // Reload to get the updated list with IDs
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving savings account: $e')),
        );
      }
    }
  }

  void _editSavingsAccount(SavingsAccount account) async {
    final result = await Navigator.push<SavingsAccount>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSavingsAccountScreen(account: account),
      ),
    );

    if (result != null) {
      try {
        await _dbService.updateSavingsAccount(result);
        _loadSavingsAccounts(); // Reload to get the updated list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating savings account: $e')),
        );
      }
    }
  }

  void _deleteSavingsAccount(SavingsAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Account'),
        content: Text('Are you sure you want to delete "${account.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && account.id != null) {
      try {
        await _dbService.deleteSavingsAccount(account.id!);
        _loadSavingsAccounts(); // Reload to get the updated list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting savings account: $e')),
        );
      }
    }
  }

  double get _totalSavings {
    final rates = Provider.of<ExchangeRates>(context, listen: false);
    final usdRate = rates.usd;
    final eurRate = rates.eur;

    // Calculate total depends on the selected currency
    return _savingsAccounts.fold(0.0, (sum, account) {
      if (_selectedCurrency == 'UAH') {
        //count all the account money of the selected currency
        if (account.currency == 'UAH') {
          sum += (account.amount / usdRate);
          //print('curr $amount ${account.currency}');
        }
      } else if (_selectedCurrency == 'USD') {
        if (account.currency == 'USD') {
          sum += account.amount;
          //print('curr $amount ${account.currency}');
        }
      } else if (_selectedCurrency == 'EUR') {
        if (account.currency == 'EUR') {
          sum += account.amount;
        }
      } else {
        // count total for all currencies, converting to UAH using the rates
        if (account.currency == 'USD') {
          sum += account.amount;
        } else if (account.currency == 'EUR') {
          sum += account.amount * eurRate / usdRate;
        } else if (account.currency == 'UAH') {
          sum += account.amount / usdRate;
        }
      }
      return sum;
    });
  }

  Future<void> _loadRates() async {
    final response = await http.get(
      Uri.parse(
        'https://api.privatbank.ua/p24api/pubinfo?exchange&json&coursid=5',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final usd = data.firstWhere((item) => item['ccy'] == 'USD');
      final eur = data.firstWhere((item) => item['ccy'] == 'EUR');
      final usdSale = double.parse(usd['sale']).toStringAsFixed(2);
      final eurSale = double.parse(eur['sale']).toStringAsFixed(2);

      setState(() {
        _ratesText = 'USD: $usdSale \nEUR: $eurSale';
      });
    } else {
      setState(() {
        _ratesText = 'Failed to load rates';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rates = Provider.of<ExchangeRates>(context, listen: false);
    final usdRate = rates.usd;
    final eurRate = rates.eur;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('UAH'),
                        selected: _selectedCurrency == 'UAH',
                        onSelected: (_) => setState(() {
                          _selectedCurrency = 'UAH';
                          _loadSavingsAccounts();
                        }),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('USD'),
                        selected: _selectedCurrency == 'USD',
                        onSelected: (_) => setState(() {
                          _selectedCurrency = 'USD';
                          _loadSavingsAccounts();
                        }),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('EUR'),
                        selected: _selectedCurrency == 'EUR',
                        onSelected: (_) => setState(() {
                          _selectedCurrency = 'EUR';
                          _loadSavingsAccounts();
                        }),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCurrency == 'All',
                        onSelected: (_) => setState(() {
                          _selectedCurrency = 'All';
                          _loadSavingsAccounts();
                        }),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$usdRate UAH/USD, $eurRate UAH/EUR",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${l10n.total_savings}: ${_formatTotalSavings()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _savingsAccounts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.savings_empty,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: 1.6,
                                  mainAxisExtent: 120,
                                ),
                            itemCount: _savingsAccounts.length,
                            itemBuilder: (context, index) {
                              final account = _savingsAccounts[index];
                              return SavingsAccountWidget(
                                account: account,
                                onEdit: () => _editSavingsAccount(account),
                                onDelete: () => _deleteSavingsAccount(account),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSavingsAccount,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTotalSavings() {
    String currencySymbol;
    switch (_selectedCurrency) {
      case 'USD':
        currencySymbol = r'$';
        break;
      case 'EUR':
        currencySymbol = r'€';
        break;
      case 'UAH':
        currencySymbol = r'$';
        break;
      default:
        currencySymbol = r'$';
    }
    var formatter = NumberFormat('###,000');
    String numberTotal = formatter
        .format(_totalSavings)
        .trim()
        .replaceAll(',', ' ');
    return _totalSavings > 0
        ? '$numberTotal $currencySymbol'
        : '0 $currencySymbol';
  }
}
