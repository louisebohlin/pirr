import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pirr_app/utils/time_ago.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final _textController = TextEditingController();
  bool _showDateChip = false; // controlled by Remote Config
  final Map<String, bool> _entryShowDate = {}; // per-entry visibility
  static const String _prefsKeyEntryShowDate = 'entryShowDateVisibility';

  // Moved to utils for testability: see formatTimeAgo

  @override
  void initState() {
    super.initState();
    _setupRemoteConfig();
    _loadEntryVisibility();
  }

  /// Initialize and fetch Remote Config
  Future<void> _setupRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Set default values in case fetch fails
    await remoteConfig.setDefaults({'showDateChip': true});

    // Dev-friendly settings so new values apply immediately
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint("Remote Config fetch failed: $e");
    }

    final value = remoteConfig.getBool('showDateChip');
    debugPrint('Remote Config showDateChip: $value');
    setState(() {
      _showDateChip = value;
    });
  }

  /// Helper to get the current user's "entries" collection
  CollectionReference<Map<String, dynamic>> _entriesRef() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('No authenticated user');
    }
    final uid = currentUser.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('entries');
  }

  /// Add a new entry to Firestore and log an Analytics event
  Future<void> _addEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final docRef = await _entriesRef().add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _textController.clear();

    // Log analytics event
    await FirebaseAnalytics.instance.logEvent(
      name: 'entry_created',
      parameters: {'entry_id': docRef.id, 'text_length': text.length},
    );
  }

  /// Delete an entry from Firestore and log an Analytics event
  Future<void> _deleteEntry(String docId) async {
    await _entriesRef().doc(docId).delete();

    // Log analytics event
    await FirebaseAnalytics.instance.logEvent(
      name: 'entry_deleted',
      parameters: {'entry_id': docId},
    );

    // Clean up persisted visibility for deleted entry
    if (_entryShowDate.containsKey(docId)) {
      setState(() {
        _entryShowDate.remove(docId);
      });
      await _saveEntryVisibility();
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
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Write something...',
                    ),
                  ),
                ),
                IconButton(onPressed: _addEntry, icon: const Icon(Icons.send)),
              ],
            ),
          ),
          // Real-time list of entries
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? const Stream.empty()
                  : _entriesRef()
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
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
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No entries yet'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final show = _entryShowDate[doc.id] ?? _showDateChip;
                    return ListTile(
                      title: Text(data['text'] ?? ''),
                      // Only show date if Remote Config flag is true
                      subtitle: (show)
                          ? Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.schedule, size: 18),
                                  label: Text(
                                    (() {
                                      final ts = data['createdAt'];
                                      if (ts is Timestamp) {
                                        final dt = ts.toDate().toLocal();
                                        return '${DateFormat('yyyy-MM-dd HH:mm:ss').format(dt)} • ${formatTimeAgo(dt)}';
                                      }
                                      return 'just now';
                                    })(),
                                  ),
                                ),
                              ],
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: show ? 'Hide date' : 'Show date',
                            icon: Icon(
                              show ? Icons.schedule : Icons.schedule_outlined,
                            ),
                            onPressed: () async {
                              setState(() {
                                _entryShowDate[doc.id] = !show;
                              });
                              await _saveEntryVisibility();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEntry(doc.id),
                          ),
                        ],
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
