import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @add_income.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get add_income;

  /// No description provided for @edit_income.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get edit_income;

  /// No description provided for @income_empty.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add first income.'**
  String get income_empty;

  /// No description provided for @add_expense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get add_expense;

  /// No description provided for @edit_expense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get edit_expense;

  /// No description provided for @expenses_empty.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add first expense.'**
  String get expenses_empty;

  /// No description provided for @add_savings.
  ///
  /// In en, this message translates to:
  /// **'Add Savings'**
  String get add_savings;

  /// No description provided for @edit_savings.
  ///
  /// In en, this message translates to:
  /// **'Edit Savings'**
  String get edit_savings;

  /// No description provided for @total_savings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get total_savings;

  /// No description provided for @savings_empty.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add an account.'**
  String get savings_empty;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @usd_equivalent.
  ///
  /// In en, this message translates to:
  /// **'Equivalent:'**
  String get usd_equivalent;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @currency_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a currency'**
  String get currency_hint;

  /// No description provided for @currency_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select a currency'**
  String get currency_validator;

  /// No description provided for @amount_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get amount_hint;

  /// No description provided for @amount_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get amount_validator;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @source_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the source of the transaction'**
  String get source_hint;

  /// No description provided for @source_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter the source of the transaction'**
  String get source_validator;

  /// No description provided for @savings_src.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get savings_src;

  /// No description provided for @savings_src_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the savings account name'**
  String get savings_src_hint;

  /// No description provided for @savings_src_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name of the savings account'**
  String get savings_src_validator;

  /// No description provided for @note_add.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get note_add;

  /// No description provided for @note_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get note_hint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @export_data.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get export_data;

  /// No description provided for @import_data.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get import_data;

  /// No description provided for @clear_db.
  ///
  /// In en, this message translates to:
  /// **'Clear Database'**
  String get clear_db;

  /// No description provided for @clear_db_hint.
  ///
  /// In en, this message translates to:
  /// **'Delete all transactions, savings and sources'**
  String get clear_db_hint;

  /// No description provided for @income_src.
  ///
  /// In en, this message translates to:
  /// **'Income Sources'**
  String get income_src;

  /// No description provided for @income_src_hint.
  ///
  /// In en, this message translates to:
  /// **'Manage income sources and categories'**
  String get income_src_hint;

  /// No description provided for @expense_src.
  ///
  /// In en, this message translates to:
  /// **'Expense Categories'**
  String get expense_src;

  /// No description provided for @expense_src_hint.
  ///
  /// In en, this message translates to:
  /// **'Manage expense categories'**
  String get expense_src_hint;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @what_new.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get what_new;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
