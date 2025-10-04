import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_avatars.dart';
import '../models/user_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      
      if (user != null) {
        // Create user document with random avatar
        await createUserDocument(user.uid);
      }
      
      return user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> createUserDocument(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    
    if (!doc.exists) {
      Map<String, dynamic> avatar = AppAvatars.generateAvatar();
      UserData userData = UserData(
        userId: userId,
        avatarIcon: avatar['icon'],
        avatarColor: avatar['color'],
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(userId).set(userData.toMap());
    }
  }

  Future<Map<String, dynamic>?> getUserAvatar(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'icon': data['avatarIcon'],
        'color': data['avatarColor'],
      };
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}