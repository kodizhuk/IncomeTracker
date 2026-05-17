// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get savings => 'Savings';

  @override
  String get add_income => 'Add Income';

  @override
  String get edit_income => 'Edit Income';

  @override
  String get add_expense => 'Add Expense';

  @override
  String get edit_expense => 'Edit Expense';

  @override
  String get add_savings => 'Add Savings';

  @override
  String get edit_savings => 'Edit Savings';

  @override
  String get amount => 'Amount';

  @override
  String get currency => 'Currency';

  @override
  String get usd_equivalent => 'Equivalent:';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get date => 'Date';

  @override
  String get currency_hint => 'Select a currency';

  @override
  String get currency_validator => 'Please select a currency';

  @override
  String get amount_hint => 'Enter an amount';

  @override
  String get amount_validator => 'Please enter an amount';

  @override
  String get source => 'Source';

  @override
  String get source_hint => 'Enter the source of the transaction';

  @override
  String get source_validator => 'Please enter the source of the transaction';

  @override
  String get savings_src => 'Account Name';

  @override
  String get savings_src_hint => 'Enter the savings account name';

  @override
  String get savings_src_validator => 'Please enter the name of the savings account';

  @override
  String get note_add => 'Add Note';

  @override
  String get note_hint => 'Optional';
}
