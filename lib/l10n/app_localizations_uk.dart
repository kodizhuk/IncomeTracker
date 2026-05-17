// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get income => 'Прибуток';

  @override
  String get expenses => 'Витрати';

  @override
  String get savings => 'Заощадження';

  @override
  String get add_income => 'Додати прибуток';

  @override
  String get edit_income => 'Редагувати прибуток';

  @override
  String get add_expense => 'Додати витрати';

  @override
  String get edit_expense => 'Редагувати витрати';

  @override
  String get add_savings => 'Додати заощадження';

  @override
  String get edit_savings => 'Редагувати заощадження';

  @override
  String get amount => 'Сума';

  @override
  String get currency => 'Валюта';

  @override
  String get usd_equivalent => 'Еквівалент:';

  @override
  String get save => 'Зберегти';

  @override
  String get update => 'Оновити';

  @override
  String get date => 'Дата';

  @override
  String get currency_hint => 'Виберіть валюту';

  @override
  String get currency_validator => 'Будь ласка, виберіть валюта';

  @override
  String get amount_hint => 'Введіть суму';

  @override
  String get amount_validator => 'Будь ласка, введіть суму';

  @override
  String get source => 'Джерело';

  @override
  String get source_hint => 'Введіть джерело транзакції';

  @override
  String get source_validator => 'Будь ласка, введите джерело транзакції';

  @override
  String get savings_src => 'Назва аккаунта';

  @override
  String get savings_src_hint => 'Введіть назву аккаунта';

  @override
  String get savings_src_validator => 'Будь ласка, введіть назву аккаунта';

  @override
  String get note_add => 'Добавити нотатку';

  @override
  String get note_hint => 'Необовязково';
}
