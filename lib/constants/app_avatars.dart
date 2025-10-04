import 'package:flutter/material.dart';
import 'dart:math';

class AppAvatars {
  static final List<String> icons = [
    '👻', '🎭', '⭐', '🌙', '🔮', '💫', 
    '🦋', '🌸', '🍃', '🎪', '🎨', '🎭'
  ];
  
  static final List<Color> colors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B9D),
    Color(0xFF48DBfB),
    Color(0xFFFECA57),
    Color(0xFF00D2D3),
    Color(0xFFEE5A6F),
    Color(0xFF9C88FF),
    Color(0xFFFFA502),
  ];
  
  static String getRandomIcon() {
    return icons[Random().nextInt(icons.length)];
  }
  
  static Color getRandomColor() {
    return colors[Random().nextInt(colors.length)];
  }
  
  static Map<String, dynamic> generateAvatar() {
    return {
      'icon': getRandomIcon(),
      'color': getRandomColor().value,
    };
  }
}