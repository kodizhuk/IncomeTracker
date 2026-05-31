import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'edit_sources_screen.dart';
import 'edit_categories_screen.dart';
import '../l10n/app_localizations.dart';

import 'package:forui/forui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usdController = TextEditingController(
    text: '42',
  );
  final TextEditingController _eurController = TextEditingController(
    text: '51',
  );

  @override
  void dispose() {
    _usdController.dispose();
    _eurController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    try {
      final rates = await DatabaseService().getExchangeRates();
      setState(() {
        _usdController.text = rates['usd']!.toString().replaceAll(
          RegExp(r'\.0+\$'),
          '',
        );
        _eurController.text = rates['eur']!.toString().replaceAll(
          RegExp(r'\.0+\$'),
          '',
        );
      });
    } catch (e) {
      // leave defaults
    }
  }

  void _editTheme() {}
  void _editLanguage() {}

  void _editIncomeSources() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditSourcesScreen()),
    );
  }

  void _editExpenseSources() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditCategoriesScreen()),
    );
  }

  void _openUpdates() {}
  void _openAbout() {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: 'Money Tracker',
      applicationVersion: '0.0.1',
      applicationLegalese: '© 2026 Money Tracker App',
      children: [const SizedBox(height: 16), Text(l10n.about_text)],
    );
  }

  void _exportData() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting database...')));
    try {
      // final path = await DatabaseService().exportDatabase();
      final path = await DatabaseService().exportDBToCsv();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Database exported to $path')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exporting database: $e')));
    }
  }

  void _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Importing CSV...')));
      final file = File(path);
      final csvContent = await file.readAsString();
      await DatabaseService().importFromCsv(csvContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV imported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing CSV: $e')));
    }
  }

  void _clearDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clear_db),
        content: const Text(
          'This will permanently delete all your transactions, savings accounts, and sources. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await DatabaseService().clearDatabase();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database cleared successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing database: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [
                FItemGroup.merge(
                  enabled: true,
                  divider: .full,
                  children: [
                    .group(
                      // Theme and language
                      children: [
                        .item(
                          prefix: const Icon(Icons.palette),
                          title: Text(l10n.theme),
                          suffix: const Icon(Icons.arrow_forward_ios),
                          // subtitle: Text(l10n.theme_hint),
                          onPress: () {
                            _editTheme();
                          },
                        ),
                        .item(
                          prefix: const Icon(Icons.language),
                          title: Text(l10n.language),
                          suffix: const Icon(Icons.arrow_forward_ios),
                          details: Text('English, Українська'),
                          onPress: () {
                            _editLanguage();
                          },
                        ),
                      ],
                    ),

                    .group(
                      // Income/expense sources and categories
                      children: [
                        .item(
                          prefix: const Icon(Icons.edit),
                          title: Text(l10n.income_src),
                          suffix: const Icon(Icons.arrow_forward_ios),
                          // details: Text(l10n.income_src_hint),
                          onPress: () {
                            _editIncomeSources();
                          },
                        ),
                        .item(
                          prefix: const Icon(Icons.edit),
                          title: Text(l10n.expense_src),
                          suffix: const Icon(Icons.arrow_forward_ios),
                          // details: Text(l10n.expense_src_hint),
                          onPress: () {
                            _editExpenseSources();
                          },
                        ),
                      ],
                    ),

                    .group(
                      // Updates, about
                      children: [
                        .item(
                          prefix: const Icon(Icons.newspaper),
                          title: Text(l10n.what_new),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text('Version 0.0.1'),
                          onPress: () {
                            _openUpdates();
                          },
                        ),
                        .item(
                          prefix: const Icon(Icons.info),
                          title: Text(l10n.about),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          // subtitle: Text('Money Tracker v0.0.1'),
                          details: const Text('Money Tracker v0.0.1'),
                          onPress: () {
                            _openAbout();
                          },
                        ),
                      ],
                    ),

                    .group(
                      // Import/export/clear database
                      children: [
                        .item(
                          prefix: const Icon(Icons.upload),
                          title: Text(l10n.export_data),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text(l10n.to_csv),
                          onPress: () async {
                            _exportData();
                          },
                        ),
                        .item(
                          prefix: const Icon(Icons.download),
                          title: Text(l10n.import_data),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text(l10n.from_csv),
                          onPress: () async {
                            _importData();
                          },
                        ),
                        .item(
                          prefix: const Icon(Icons.delete),
                          title: Text(l10n.clear_db),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text(l10n.clear_db_hint),
                          onPress: () async {
                            _clearDatabase();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
