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
      print('AuthService: Starting anonymous sign-in...');
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      
      print('AuthService: Sign-in result - User: ${user?.uid}, isAnonymous: ${user?.isAnonymous}');
      
      if (user != null) {
        // Create user document with random avatar
        print('AuthService: Creating user document...');
        await createUserDocument(user.uid);
        print('AuthService: User document created successfully');
      }
      
      return user;
    } catch (e) {
      print('AuthService: Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> createUserDocument(String userId) async {
    try {
      print('AuthService: Checking if user document exists for: $userId');
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        print('AuthService: Creating new user document...');
        Map<String, dynamic> avatar = AppAvatars.generateAvatar();
        print('AuthService: Generated avatar: $avatar');
        
        UserData userData = UserData(
          userId: userId,
          avatarIcon: avatar['icon'],
          avatarColor: avatar['color'],
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(userId).set(userData.toMap());
        print('AuthService: User document created successfully');
      } else {
        print('AuthService: User document already exists');
      }
    } catch (e) {
      print('AuthService: Error creating user document: $e');
      rethrow;
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