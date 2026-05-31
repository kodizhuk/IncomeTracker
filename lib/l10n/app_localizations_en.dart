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
  String get statistics => 'Statistics';

  @override
  String get add_income => 'Add Income';

  @override
  String get edit_income => 'Edit Income';

  @override
  String get income_empty => 'Tap the + to add first income.';

  @override
  String get add_expense => 'Add Expense';

  @override
  String get edit_expense => 'Edit Expense';

  @override
  String get expenses_empty => 'Tap the + to add first expense.';

  @override
  String get add_savings => 'Add Savings';

  @override
  String get edit_savings => 'Edit Savings';

  @override
  String get total_savings => 'Total Savings';

  @override
  String get savings_empty => 'Tap the + to add an account.';

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

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get export_data => 'Export Data';

  @override
  String get to_csv => 'to CSV file';

  @override
  String get import_data => 'Import Data';

  @override
  String get from_csv => 'from CSV file';

  @override
  String get clear_db => 'Clear Database';

  @override
  String get clear_db_hint => 'Delete all transactions, savings and sources';

  @override
  String get income_src => 'Income Sources';

  @override
  String get income_src_hint => 'Manage income sources and categories';

  @override
  String get expense_src => 'Expense Categories';

  @override
  String get expense_src_hint => 'Manage expense categories';

  @override
  String get about => 'About';

  @override
  String get what_new => 'What\'s New';

  @override
  String get theme => 'Theme';

  @override
  String get theme_hint => 'Switch between light and dark themes';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get total_income => 'Total Income';

  @override
  String get about_text => '\tIncomeTracker is a financial app that simplifies managing your income, expenses, and long-term savings in one place.\n\n\tIt features detailed visual statistics to break down earnings by category and includes a built-in calculator to automatically determine your church tithe.\n\n\t No AD, no tracking, all data are saved in local database on your device.';
}
