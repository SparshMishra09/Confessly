import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String userId;
  final String avatarIcon;
  final int avatarColor;
  final DateTime createdAt;
  final int postCount;

  UserData({
    required this.userId,
    required this.avatarIcon,
    required this.avatarColor,
    required this.createdAt,
    this.postCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'avatarIcon': avatarIcon,
      'avatarColor': avatarColor,
      'createdAt': Timestamp.fromDate(createdAt),
      'postCount': postCount,
    };
  }
}