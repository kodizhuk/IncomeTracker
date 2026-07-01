import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'database_service.dart';

class ExchangeRates extends ChangeNotifier {
  double usd = 42.0;
  double eur = 51.0;
  bool loaded = false;

  final DatabaseService _db = DatabaseService();

  /// Load rates from local storage first, then try to refresh from remote API.
  Future<void> load() async {
    try {
      // Read persisted rates (database may use 'usd' or 'usd_rate')
      final persisted = await _db.getExchangeRates();
      if (persisted.containsKey('usd')) {
        usd = (persisted['usd'] as num).toDouble();
      } else if (persisted.containsKey('usd_rate')) {
        usd = (persisted['usd_rate'] as num).toDouble();
      }

      // Try fetching latest rates from PrivatBank
      final response = await http.get(
        Uri.parse(
          'https://api.privatbank.ua/p24api/pubinfo?exchange&json&coursid=5',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        final usdItem = data.firstWhere(
          (item) => item['ccy'] == 'USD',
          orElse: () => null,
        );
        final eurItem = data.firstWhere(
          (item) => item['ccy'] == 'EUR',
          orElse: () => null,
        );

        if (usdItem != null && usdItem['sale'] != null) {
          final parsed = double.tryParse(usdItem['sale'].toString());
          if (parsed != null) {
            usd = parsed;
            // persist USD rate to database (DatabaseService expects currency + usdRate)
            try {
              await _db.setExchangeRates('UAH', usd);
            } catch (_) {}
          }
        }

        if (eurItem != null && eurItem['sale'] != null) {
          final parsedEur = double.tryParse(eurItem['sale'].toString());
          if (parsedEur != null) eur = parsedEur;
        }
      }
    } catch (_) {
      // ignore network/parse errors and keep existing rates
    } finally {
      loaded = true;
      notifyListeners();
    }
  }

  // Helper to get rate by currency code
  double rate(String code) => code.toLowerCase() == 'usd' ? usd : eur;
}
