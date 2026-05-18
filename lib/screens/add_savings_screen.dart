import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:my_money/l10n/app_localizations.dart';
import '../models/savings_account.dart';
import '../services/database_service.dart';

class AddEditSavingsAccountScreen extends StatefulWidget {
  final SavingsAccount? account;

  const AddEditSavingsAccountScreen({super.key, this.account});

  @override
  State<AddEditSavingsAccountScreen> createState() =>
      _AddEditSavingsAccountScreenState();
}

class _AddEditSavingsAccountScreenState
    extends State<AddEditSavingsAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final FSelectController<String> _currencyController =
      FSelectController<String>();
  String _selectedCurrency = 'UAH';
  final double _usdRate = 42.0;
  double? _convertedUsdAmount;
  final supported_currencies = ['UAH', 'USD', 'EUR'];

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      _amountController.text = widget.account!.amount.toString();
      _currencyController.value = widget.account!.currency;

      _nameController.text = widget.account!.name;
      _notesController.text = widget.account!.notes ?? '';
      _selectedCurrency = widget.account!.currency;
    } else {
      _currencyController.value = supported_currencies.first;
    }

    _updateConvertedUsdAmount();
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
    final isEditing = widget.account != null;
    final l10n = AppLocalizations.of(context)!;

    final theme = FTheme.of(context);
    final colors = theme.colors;
    final text = theme.typography;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Savings Account' : 'Add Savings Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source input
              FTextFormField(
                control: .managed(controller: _nameController),
                hint: l10n.savings_src_hint,
                label: Text(l10n.savings_src),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.savings_src_validator;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Amount input
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
                  // Currency selector
                  Expanded(
                    flex: 4,
                    child: FSelect<String>.rich(
                      control: .managed(
                        controller: _currencyController,
                        onChange: (value) => _updateConvertedUsdAmount(),
                      ),
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
              // show USD equivalent is UAH is active
              if (_currencyController.value == 'UAH' &&
                  _convertedUsdAmount != null) ...[
                const SizedBox(height: 10),
                Text(
                  '${l10n.usd_equivalent} ${_convertedUsdAmount!.toStringAsFixed(2)} \$',
                  style: text.sm.copyWith(color: colors.primary),
                ),
              ],
              const SizedBox(height: 16),
              // Notes input
              FTextFormField(
                control: .managed(
                  controller: _notesController,
                  onChange: (value) {
                    _updateConvertedUsdAmount();
                  },
                ),
                hint: l10n.note_hint,
                label: Text(l10n.note_add),
              ),
              const SizedBox(height: 16),
              //Save button
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid
                          _saveAccount();
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

  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final rates = await DatabaseService().getExchangeRates();
      final usdRate = rates['usd'] ?? _usdRate;
      final account = SavingsAccount(
        id: widget.account?.id,
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        amountUSD: _selectedCurrency == 'USD'
            ? double.parse(_amountController.text)
            : (double.parse(_amountController.text) / usdRate * 100).round() /
                  100.0,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        currency: _currencyController.value!,
        lastUpdated: DateTime.now(),
      );

      Navigator.pop(context, account);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
