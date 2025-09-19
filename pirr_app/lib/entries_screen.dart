import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pirr_app/utils/time_ago.dart';
import 'package:pirr_app/models/entry.dart';
import 'package:pirr_app/services/entry_service.dart';
import 'package:pirr_app/services/remote_config_service.dart';
import 'package:pirr_app/services/analytics_service.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final _textController = TextEditingController();
  final _entryService = EntryService();
  final _remoteConfigService = RemoteConfigService();
  final _analyticsService = AnalyticsService();

  bool _showDateChip = false; // controlled by Remote Config
  final Map<String, bool> _entryShowDate = {}; // per-entry visibility
  static const String _prefsKeyEntryShowDate = 'entryShowDateVisibility';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Log screen view for Analytics
    await _analyticsService.logScreenView(screenName: 'EntriesScreen');

    // Log feature usage for Remote Config
    await _analyticsService.logFeatureUsage(
      featureName: 'remote_config_initialized',
      parameters: {
        'show_date_chip': _remoteConfigService.showDateChip,
        'max_entry_length': _remoteConfigService.maxEntryLength,
      },
    );

    // Initialize Remote Config
    await _remoteConfigService.initialize();
    setState(() {
      _showDateChip = _remoteConfigService.showDateChip;
    });

    // Load entry visibility preferences
    await _loadEntryVisibility();
  }

  /// Add a new entry using the service layer
  Future<void> _addEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      await _entryService.addEntry(text);
      _textController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding entry: $e')));
      }
    }
  }

  /// Delete an entry using the service layer
  Future<void> _deleteEntry(String entryId) async {
    try {
      await _entryService.deleteEntry(entryId);

      // Clean up persisted visibility for deleted entry
      if (_entryShowDate.containsKey(entryId)) {
        setState(() {
          _entryShowDate.remove(entryId);
        });
        await _saveEntryVisibility();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
      }
    }
  }

  Future<void> _loadEntryVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyEntryShowDate);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        decoded.forEach((key, value) {
          if (value is bool) {
            _entryShowDate[key] = value;
          }
        });
        if (mounted) setState(() {});
      }
    } catch (_) {
      // ignore malformed data
    }
  }

  Future<void> _saveEntryVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entryShowDate);
    await prefs.setString(_prefsKeyEntryShowDate, raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Entries'),
        actions: [
          IconButton(
            onPressed: () async {
              await _analyticsService.logLogout();
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Input field + send button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Write something...',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _addEntry,
                      icon: const Icon(Icons.send),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Real-time list of entries
          Expanded(
            child: StreamBuilder<List<Entry>>(
              stream: _entryService.getEntriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (FirebaseAuth.instance.currentUser == null) {
                  return const Center(child: Text('Please sign in'));
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return const Center(child: Text('No entries yet'));
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final show = _entryShowDate[entry.id] ?? _showDateChip;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(entry.text),
                        // Always show toggle icon; conditionally show date text
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: show ? 'Hide date' : 'Show date',
                              icon: Icon(
                                show ? Icons.schedule : Icons.schedule_outlined,
                                size: 18,
                              ),
                              onPressed: () async {
                                setState(() {
                                  _entryShowDate[entry.id] = !show;
                                });
                                await _saveEntryVisibility();

                                // Log analytics for date visibility toggle
                                await _analyticsService.logFeatureUsage(
                                  featureName: 'date_visibility_toggle',
                                  parameters: {
                                    'entry_id': entry.id,
                                    'show_date': !show,
                                    'is_global_setting':
                                        _entryShowDate[entry.id] == null,
                                  },
                                );
                              },
                            ),
                            if (show) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(entry.createdAt)} • ${formatTimeAgo(entry.createdAt)}',
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEntry(entry.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
