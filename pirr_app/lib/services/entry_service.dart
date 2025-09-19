import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pirr_app/models/entry.dart';
import 'package:pirr_app/services/analytics_service.dart';

/// Service class for managing entries in Firestore
class EntryService {
  static final EntryService _instance = EntryService._internal();
  factory EntryService() => _instance;
  EntryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analyticsService = AnalyticsService();

  /// Get the current user, throwing if not authenticated
  User _getCurrentUser() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('No authenticated user');
    }
    return currentUser;
  }

  /// Get the current user's entries collection reference
  CollectionReference<Map<String, dynamic>> _getEntriesRef() {
    return _firestore
        .collection('users')
        .doc(_getCurrentUser().uid)
        .collection('entries');
  }

  /// Get a stream of entries for the current user, ordered by creation date
  Stream<List<Entry>> getEntriesStream() {
    try {
      return _getEntriesRef()
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Entry.fromFirestore(doc)).toList(),
          );
    } catch (e) {
      // Return empty stream if user not authenticated
      return Stream.value([]);
    }
  }

  /// Add a new entry
  Future<String> addEntry(String text) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Entry text cannot be empty');
    }

    final currentUser = _getCurrentUser();
    final entryData = {
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUser.uid,
    };

    final docRef = await _getEntriesRef().add(entryData);

    // Log analytics event
    await _analyticsService.logEvent(
      eventName: 'entry_created',
      parameters: {'entry_id': docRef.id, 'text_length': text.trim().length},
    );

    return docRef.id;
  }

  /// Delete an entry
  Future<void> deleteEntry(String entryId) async {
    _getCurrentUser(); // Ensure user is authenticated
    await _getEntriesRef().doc(entryId).delete();

    // Log analytics event
    await _analyticsService.logEvent(
      eventName: 'entry_deleted',
      parameters: {'entry_id': entryId},
    );
  }

  /// Update an entry
  Future<void> updateEntry(String entryId, String newText) async {
    if (newText.trim().isEmpty) {
      throw ArgumentError('Entry text cannot be empty');
    }

    _getCurrentUser(); // Ensure user is authenticated
    await _getEntriesRef().doc(entryId).update({
      'text': newText.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Log analytics event
    await _analyticsService.logEvent(
      eventName: 'entry_updated',
      parameters: {'entry_id': entryId, 'text_length': newText.trim().length},
    );
  }

  /// Get a single entry by ID
  Future<Entry?> getEntry(String entryId) async {
    try {
      final doc = await _getEntriesRef().doc(entryId).get();
      if (doc.exists) {
        return Entry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
