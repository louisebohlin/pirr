import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final _textController = TextEditingController();

  /// Hjälpfunktion för att hämta path till "entries" för inloggad användare
  CollectionReference<Map<String, dynamic>> _entriesRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('entries');
  }

  Future<void> _addEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final docRef = await _entriesRef().add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _textController.clear();

    // 🔥 Logga analytics-event
    await FirebaseAnalytics.instance.logEvent(
      name: 'entry_created',
      parameters: {'entry_id': docRef.id, 'text_length': text.length},
    );
  }

  Future<void> _deleteEntry(String docId) async {
    await _entriesRef().doc(docId).delete();

    // 🔥 Logga analytics-event
    await FirebaseAnalytics.instance.logEvent(
      name: 'entry_deleted',
      parameters: {'entry_id': docId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Entries"),
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: "Write something...",
                    ),
                  ),
                ),
                IconButton(onPressed: _addEntry, icon: const Icon(Icons.send)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _entriesRef()
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("No entries yet"));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    return ListTile(
                      title: Text(data['text'] ?? ''),
                      subtitle: data['createdAt'] != null
                          ? Text(
                              data['createdAt'].toDate().toString().substring(
                                0,
                                16,
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEntry(doc.id),
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
