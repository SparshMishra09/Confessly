import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/confession_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Post a new confession
  Future<void> postConfession(Confession confession) async {
    try {
      print('FirestoreService: Attempting to post confession for user: ${confession.userId}');
      print('FirestoreService: Confession data: ${confession.toMap()}');
      DocumentReference docRef = await _firestore.collection('confessions').add(confession.toMap());
      print('FirestoreService: Confession posted successfully with ID: ${docRef.id}');
    } catch (e) {
      print('FirestoreService: Error posting confession: $e');
      rethrow;
    }
  }

  // Get latest confessions
  Stream<List<Confession>> getLatestConfessions({int limit = 20}) {
    return _firestore
        .collection('confessions')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Confession.fromFirestore(doc))
            .toList());
  }

  // Get trending confessions (by reaction count, simplified query)
  Stream<List<Confession>> getTrendingConfessions({int limit = 20}) {
    try {
      // Get all confessions and sort by reaction count in-memory
      return _firestore
          .collection('confessions')
          .snapshots()
          .map((snapshot) {
            List<Confession> confessions = snapshot.docs
                .map((doc) => Confession.fromFirestore(doc))
                .toList();
            
            // Sort by reaction count (highest first), then by timestamp (newest first) as tie-breaker
            confessions.sort((a, b) {
              if (a.reactionCount != b.reactionCount) {
                return b.reactionCount.compareTo(a.reactionCount); // Higher reactions first
              }
              return b.timestamp.compareTo(a.timestamp); // Newer first as tie-breaker
            });
            
            // Take only the top trending confessions
            return confessions.take(limit).toList();
          })
          .handleError((error) {
            print('Error in getTrendingConfessions: $error');
            // Return empty stream on error
            return Stream.value(<Confession>[]);
          });
    } catch (e) {
      print('Error setting up getTrendingConfessions stream: $e');
      // Return empty stream on error
      return Stream.value(<Confession>[]);
    }
  }

  // Get user's confessions
  Stream<List<Confession>> getUserConfessions(String userId) {
    try {
      return _firestore
          .collection('confessions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Confession.fromFirestore(doc))
              .toList())
          .handleError((error) {
            print('Error in getUserConfessions: $error');
            // Return empty stream on error
            return Stream.value(<Confession>[]);
          });
    } catch (e) {
      print('Error setting up getUserConfessions stream: $e');
      // Return empty stream on error
      return Stream.value(<Confession>[]);
    }
  }

  // Add reaction to confession (one reaction per user)
  Future<void> addReaction(String confessionId, String emoji, String userId) async {
    try {
      DocumentReference confessionRef = _firestore.collection('confessions').doc(confessionId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(confessionRef);
        
        if (!snapshot.exists) {
          throw Exception("Confession does not exist!");
        }
        
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Map<String, int> reactions = Map<String, int>.from(data['reactions'] ?? {});
        List<String> reactedUsers = List<String>.from(data['reactedUsers'] ?? []);
        
        // Check if user has already reacted
        if (reactedUsers.contains(userId)) {
          throw Exception("You can only react once per confession!");
        }
        
        // Add user to reacted users list
        reactedUsers.add(userId);
        
        // Increment reaction count
        reactions[emoji] = (reactions[emoji] ?? 0) + 1;
        
        int totalReactions = reactions.values.fold(0, (total, reactionCount) => total + reactionCount);
        
        transaction.update(confessionRef, {
          'reactions': reactions,
          'reactionCount': totalReactions,
          'reactedUsers': reactedUsers,
        });
      });
    } catch (e) {
      print('Error adding reaction: $e');
      rethrow;
    }
  }

  // Delete confession
  Future<void> deleteConfession(String confessionId) async {
    try {
      await _firestore.collection('confessions').doc(confessionId).delete();
    } catch (e) {
      print('Error deleting confession: $e');
      rethrow;
    }
  }

  // Check if user can post (rate limiting)
  Future<bool> canUserPost(String userId) async {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    
    QuerySnapshot posts = await _firestore
        .collection('confessions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
        .get();
    
    return posts.docs.length < 5; // Max 5 posts per day
  }
}