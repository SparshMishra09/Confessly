class ModerationService {
  static final List<String> blockedWords = [
    // Add inappropriate words here
    'spam',
    'scam',
    'hack',
    // Add more as needed
  ];

  static bool isContentSafe(String text) {
    String lowerText = text.toLowerCase();
    
    // Check for blocked words
    for (String word in blockedWords) {
      if (lowerText.contains(word.toLowerCase())) {
        return false;
      }
    }
    
    // Check for excessive caps (possible spam)
    int capsCount = text.replaceAll(RegExp(r'[^A-Z]'), '').length;
    if (text.length > 10 && capsCount > text.length * 0.7) {
      return false;
    }
    
    return true;
  }

  static String? validateConfession(String text) {
    if (text.trim().isEmpty) {
      return 'Confession cannot be empty';
    }
    
    if (text.length < 10) {
      return 'Confession must be at least 10 characters';
    }
    
    if (text.length > 500) {
      return 'Confession cannot exceed 500 characters';
    }
    
    if (!isContentSafe(text)) {
      return 'Your confession contains inappropriate content';
    }
    
    return null; // No errors
  }
}