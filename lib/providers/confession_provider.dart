import 'package:flutter/foundation.dart';
import '../models/confession_model.dart';
import '../services/firestore_service.dart';

class ConfessionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Confession> _confessions = [];
  bool _isLoading = false;
  String _sortBy = 'latest'; // 'latest' or 'trending'

  List<Confession> get confessions => _confessions;
  bool get isLoading => _isLoading;
  String get sortBy => _sortBy;

  void toggleSort() {
    _sortBy = _sortBy == 'latest' ? 'trending' : 'latest';
    notifyListeners();
  }

  Stream<List<Confession>> getConfessionsStream() {
    if (_sortBy == 'latest') {
      return _firestoreService.getLatestConfessions();
    } else {
      return _firestoreService.getTrendingConfessions();
    }
  }

  Future<void> postConfession(Confession confession) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestoreService.postConfession(confession);
    } catch (e) {
      print('Error in provider: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReaction(String confessionId, String emoji, String userId) async {
    try {
      await _firestoreService.addReaction(confessionId, emoji, userId);
    } catch (e) {
      print('Error adding reaction: $e');
      rethrow; // Let the UI handle the error message
    }
  }

  Future<void> deleteConfession(String confessionId) async {
    try {
      await _firestoreService.deleteConfession(confessionId);
    } catch (e) {
      print('Error deleting confession: $e');
    }
  }
}