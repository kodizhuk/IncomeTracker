import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:my_money/l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type; // 'income', 'expense', or 'saving'
  final Transaction? existingTransaction;
  final List<String> defaultCategories;

  const AddTransactionScreen({
    super.key,
    required this.type,
    required this.defaultCategories,
    this.existingTransaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final FSelectController<String> _sourceController =
      FSelectController<String>();
  final FSelectController<String> _currencyController =
      FSelectController<String>();

  DateTime _selectedDate = DateTime.now();

  double? _convertedUsdAmount;
  List<String> _sources = [];
  final double _usdRate = 42.0; // default rate, will be updated from DB
  final supported_currencies = ['UAH', 'USD', 'EUR'];

  @override
  void initState() {
    super.initState();

    if (widget.existingTransaction != null) {
      // load existing transaction data into form
      _amountController.text = widget.existingTransaction!.amount.toString();
      _selectedDate = widget.existingTransaction!.date;
      _currencyController.value = widget.existingTransaction!.currency;
      _sourceController.value =
          widget.existingTransaction!.source ??
          widget.existingTransaction!.name;
      _loadSources(widget.type, false);
    } else {
      _currencyController.value = supported_currencies.first;
      _loadSources(widget.type, true);
    }

    _updateConvertedUsdAmount();
  }

  Future<void> _loadSources(String type, bool init) async {
    try {
      final rows = await DatabaseService().getSources(type);
      final names = rows.map((r) => (r['name'] as Object).toString()).toList();
      setState(() {
        _sources = names.isNotEmpty ? names : widget.defaultCategories;
        if (init) {
          _sourceController.value = _sources.isNotEmpty ? _sources.first : null;
        }
      });
    } catch (e) {
      setState(() {
        _sources = widget.defaultCategories;
      });
    }
  }

  Future<void> _updateConvertedUsdAmount() async {
    setState(() {
      // _amountController.text =
      //     _amountController.value.text; // Trigger onChange to update USD amount
      if (_currencyController.value == 'UAH') {
        final double? amount = double.tryParse(_amountController.text);
        if (amount != null) {
          _convertedUsdAmount = amount / _usdRate;
        } else {
          _convertedUsdAmount = null; // Clear if amount is invalid
        }
      } else {
        _convertedUsdAmount = null; // Clear if currency is not UAH
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTransaction != null;
    final l10n = AppLocalizations.of(context)!;

    var page_header = Text(
      isEditing
          ? widget.type == 'income'
                ? l10n.edit_income
                : widget.type == 'expense'
                ? l10n.edit_expense
                : l10n.edit_savings
          : widget.type == 'income'
          ? l10n.add_income
          : widget.type == 'expense'
          ? l10n.add_expense
          : l10n.add_savings,
    );

    final theme = FTheme.of(context);
    final colors = theme.colors;
    final text = theme.typography;

    return FScaffold(
      header: FHeader.nested(
        title: page_header,
        prefixes: [FHeaderAction.back(onPress: () => Navigator.pop(context))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: FTextFormField(
                      control: .managed(
                        controller: _amountController,
                        onChange: (value) {
                          _updateConvertedUsdAmount();
                        },
                      ),
                      hint: l10n.amount_hint,
                      label: Text(l10n.amount),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.amount_validator;
                        }
                        if (double.tryParse(value) == null) {
                          return l10n.amount_validator;
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 4,
                    child: FSelect<String>.rich(
                      control: .managed(controller: _currencyController),
                      label: Text(l10n.currency),
                      format: (s) => s,
                      hint: l10n.currency_hint,
                      validator: (currency) =>
                          currency == null ? l10n.currency_validator : null,
                      children: [
                        for (final currency in supported_currencies)
                          .item(title: Text(currency), value: currency),
                      ],
                    ),
                  ),
                ],
              ),
              if (_currencyController.value == 'UAH' &&
                  _convertedUsdAmount != null) ...[
                const SizedBox(height: 10),
                Text(
                  '${l10n.usd_equivalent} ${_convertedUsdAmount!.toStringAsFixed(2)} \$',
                  style: text.sm.copyWith(color: colors.primary),
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: FSelect<String>.rich(
                      control: .managed(controller: _sourceController),
                      label: Text(l10n.source),
                      format: (s) => s,
                      hint: l10n.source_hint,
                      validator: (source) =>
                          source == null ? l10n.source_validator : null,
                      children: [
                        for (final source in _sources)
                          .item(title: Text(source), value: source),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FDateField.calendar(
                      label: Text(l10n.date),
                      control: .managed(
                        initial: _selectedDate,
                        onChange: (date) {
                          _selectedDate = date!;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid
                          _saveTransaction();
                        }
                      },
                      child: Text(isEditing ? l10n.update : l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final rates = await DatabaseService().getExchangeRates();
      final usdRate = rates['usd'] ?? _usdRate;
      final transaction = Transaction(
        id: widget.existingTransaction?.id,
        type: widget.type,
        date: _selectedDate,
        name: _sourceController.value!,
        amount: double.parse(_amountController.text),
        amount_usd: (() {
          double amount = double.parse(_amountController.text);
          return _currencyController.value == 'UAH'
              ? (amount / usdRate * 100).round() / 100.0
              : (amount * 100).round() / 100.0;
        }()),
        source: _sourceController.value!,
        currency: _currencyController.value!,
      );

      Navigator.pop(context, transaction);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
