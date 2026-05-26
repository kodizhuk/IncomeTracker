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
  String get statistics => 'Статистика';

  @override
  String get add_income => 'Додати прибуток';

  @override
  String get edit_income => 'Редагувати прибуток';

  @override
  String get income_empty => 'Нажміть +, щоб додати перший прибуток.';

  @override
  String get add_expense => 'Додати витрати';

  @override
  String get edit_expense => 'Редагувати витрати';

  @override
  String get expenses_empty => 'Нажміть +, щоб додати перші витрати.';

  @override
  String get add_savings => 'Додати заощадження';

  @override
  String get edit_savings => 'Редагувати заощадження';

  @override
  String get total_savings => 'Сума заощаджень';

  @override
  String get savings_empty => 'Нажміть +, щоб додати аккаунт.';

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

  @override
  String get settings => 'Налаштування';

  @override
  String get language => 'Мова';

  @override
  String get export_data => 'Експот даних';

  @override
  String get import_data => 'Імпорт даних';

  @override
  String get clear_db => 'Очистити базу даних';

  @override
  String get clear_db_hint => 'Видалити всі транзакції та заощадження';

  @override
  String get income_src => 'Джерела прибутку';

  @override
  String get income_src_hint => 'Керувати списком джерел прибутку ';

  @override
  String get expense_src => 'Категорії витрат';

  @override
  String get expense_src_hint => 'Керувати категоріями витрат';

  @override
  String get about => 'Про програму';

  @override
  String get what_new => 'Що нового';

  @override
  String get theme => 'Тема';

  @override
  String get theme_hint => 'Перемикання між світлою та темною темами';

  @override
  String get month => 'Місяць';

  @override
  String get year => 'Рік';

  @override
  String get total_income => 'Загальний прибуток';
}
