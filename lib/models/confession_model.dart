import 'package:cloud_firestore/cloud_firestore.dart';

class Confession {
  final String id;
  final String userId;
  final String text;
  final String avatarIcon;
  final int avatarColor;
  final DateTime timestamp;
  final Map<String, int> reactions;
  final int reactionCount;
  final List<String> reactedUsers; // Track users who have reacted

  Confession({
    required this.id,
    required this.userId,
    required this.text,
    required this.avatarIcon,
    required this.avatarColor,
    required this.timestamp,
    required this.reactions,
    required this.reactionCount,
    this.reactedUsers = const [],
  });

  factory Confession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Confession(
      id: doc.id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      avatarIcon: data['avatarIcon'] ?? '👻',
      avatarColor: data['avatarColor'] ?? 0xFF6C63FF,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reactions: Map<String, int>.from(data['reactions'] ?? {}),
      reactionCount: data['reactionCount'] ?? 0,
      reactedUsers: List<String>.from(data['reactedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'avatarIcon': avatarIcon,
      'avatarColor': avatarColor,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactions,
      'reactionCount': reactionCount,
      'reactedUsers': reactedUsers,
    };
  }
}