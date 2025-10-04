import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/confession_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Post a new confession
  Future<void> postConfession(Confession confession) async {
    try {
      await _firestore.collection('confessions').add(confession.toMap());
    } catch (e) {
      print('Error posting confession: $e');
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

  // Get trending confessions (by reaction count, last 7 days)
  Stream<List<Confession>> getTrendingConfessions({int limit = 20}) {
    DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    
    return _firestore
        .collection('confessions')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('timestamp', descending: true)
        .orderBy('reactionCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Confession.fromFirestore(doc))
            .toList());
  }

  // Get user's confessions
  Stream<List<Confession>> getUserConfessions(String userId) {
    return _firestore
        .collection('confessions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Confession.fromFirestore(doc))
            .toList());
  }

  // Add reaction to confession
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
        
        // Increment reaction count
        reactions[emoji] = (reactions[emoji] ?? 0) + 1;
        
        int totalReactions = reactions.values.fold(0, (total, reactionCount) => total + reactionCount);
        
        transaction.update(confessionRef, {
          'reactions': reactions,
          'reactionCount': totalReactions,
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