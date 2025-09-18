import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user entry in the app
class Entry {
  final String id;
  final String text;
  final DateTime createdAt;
  final String userId;

  const Entry({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userId,
  });

  /// Create an Entry from Firestore document data
  factory Entry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Entry(
      id: doc.id,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String? ?? '',
    );
  }

  /// Convert Entry to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  /// Create a copy of this Entry with updated fields
  Entry copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? userId,
  }) {
    return Entry(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entry &&
        other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ text.hashCode ^ createdAt.hashCode ^ userId.hashCode;
  }

  @override
  String toString() {
    return 'Entry(id: $id, text: $text, createdAt: $createdAt, userId: $userId)';
  }
}
