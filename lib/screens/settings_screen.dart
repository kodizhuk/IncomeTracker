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

  void _saveRates() {
    if (!_formKey.currentState!.validate()) return;
    final currency = 'UAH';
    final usdRate = double.tryParse(_usdController.text) ?? 42.0;
    DatabaseService()
        .setExchangeRates(currency, usdRate)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved rates — USD: $usdRate')),
          );
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving rates: $e')));
        });
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
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveRates),
        ],
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
                const SizedBox(height: 15),
                FItemGroup.merge(
                  // style: const .delta(spacing: 4),
                  enabled: true,
                  // intrinsicWidth: null,
                  divider: .none,
                  children: [
                    .group(
                      children: [
                        FItem(
                          prefix: const Icon(Icons.palette),
                          title: Text(l10n.theme),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          // subtitle: Text(l10n.theme_hint),
                          onPress: () {},
                        ),
                        FItem(
                          prefix: const Icon(Icons.language),
                          title: Text(l10n.language),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text('English, Українська'),
                          onPress: () {},
                        ),
                        FItem(
                          prefix: const Icon(Icons.edit),
                          title: Text(l10n.income_src),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          // details: Text(l10n.income_src_hint),
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditSourcesScreen(),
                              ),
                            );
                          },
                        ),
                        FItem(
                          prefix: const Icon(Icons.edit),
                          title: Text(l10n.expense_src),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          // details: Text(l10n.expense_src_hint),
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditCategoriesScreen(),
                              ),
                            );
                          },
                        ),

                        FItem(
                          prefix: const Icon(Icons.newspaper),
                          title: Text(l10n.what_new),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text('Version 0.0.1'),
                          onPress: () {},
                        ),
                        FItem(
                          prefix: const Icon(Icons.info),
                          title: Text(l10n.about),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          // subtitle: Text('Money Tracker v0.0.1'),
                          details: const Text('Money Tracker v0.0.1'),
                          onPress: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Money Tracker',
                              applicationVersion: '0.0.1',
                              applicationLegalese: '© 2026 Money Tracker App',
                              children: [
                                const SizedBox(height: 16),
                                Text(l10n.about_text),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                    .group(
                      // Import/export database
                      children: [
                        FItem(
                          prefix: const Icon(Icons.upload),
                          title: Text(l10n.export_data),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text(l10n.to_csv),
                          onPress: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Exporting database...'),
                              ),
                            );
                            try {
                              // final path = await DatabaseService().exportDatabase();
                              final path = await DatabaseService()
                                  .exportDBToCsv();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Database exported to $path'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error exporting database: $e'),
                                ),
                              );
                            }
                          },
                        ),
                        FItem(
                          prefix: const Icon(Icons.download),
                          title: Text(l10n.import_data),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text(l10n.from_csv),
                          onPress: () async {
                            try {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    allowMultiple: false,
                                    type: FileType.custom,
                                    allowedExtensions: ['csv'],
                                  );
                              if (result == null || result.files.isEmpty)
                                return;
                              final path = result.files.single.path;
                              if (path == null) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Importing CSV...'),
                                ),
                              );
                              final file = File(path);
                              final csvContent = await file.readAsString();
                              await DatabaseService().importFromCsv(csvContent);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('CSV imported successfully'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error importing CSV: $e'),
                                ),
                              );
                            }
                          },
                        ),
                        FItem(
                          prefix: const Icon(Icons.delete),
                          title: Text(l10n.clear_db),
                          suffix: const Icon(Icons.arrow_forward_ios, size: 16),
                          details: Text(l10n.clear_db_hint),
                          onPress: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.clear_db),
                                content: const Text(
                                  'This will permanently delete all your transactions, savings accounts, and sources. This action cannot be undone. Are you sure?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              try {
                                await DatabaseService().clearDatabase();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Database cleared successfully',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error clearing database: $e',
                                    ),
                                  ),
                                );
                              }
                            }
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
