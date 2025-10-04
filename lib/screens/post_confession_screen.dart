import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/confession_provider.dart';
import '../providers/auth_provider.dart';
import '../models/confession_model.dart';
import '../services/moderation_service.dart';
import '../widgets/custom_button.dart';

class PostConfessionScreen extends StatefulWidget {
  @override
  _PostConfessionScreenState createState() => _PostConfessionScreenState();
}

class _PostConfessionScreenState extends State<PostConfessionScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _postConfession() async {
    final confessionProvider = Provider.of<ConfessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      _showSnackBar('Please sign in to post');
      return;
    }
    
    String text = _textController.text.trim();
    
    // Validate confession
    String? error = ModerationService.validateConfession(text);
    if (error != null) {
      _showSnackBar(error);
      return;
    }
    
    // Check rate limit
    bool canPost = await confessionProvider.canUserPost(authProvider.user!.uid);
    if (!canPost) {
      _showSnackBar('You can only post 5 confessions per day');
      return;
    }
    
    setState(() {
      _isPosting = true;
    });
    
    try {
      // Get user avatar
      Map<String, dynamic>? avatar = await authProvider.getUserAvatar();
      
      Confession confession = Confession(
        id: '',
        userId: authProvider.user!.uid,
        text: text,
        avatarIcon: avatar?['icon'] ?? '👻',
        avatarColor: avatar?['color'] ?? 0xFF6C63FF,
        timestamp: DateTime.now(),
        reactions: {},
        reactionCount: 0,
      );
      
      await confessionProvider.postConfession(confession);
      
      _showSnackBar('Confession posted successfully!');
      Navigator.pop(context);
      
    } catch (e) {
      _showSnackBar('Error posting confession');
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int charCount = _textController.text.length;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Confession', style: AppTextStyles.subheading),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              
              // Animated gradient container
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.2),
                      AppColors.secondaryBlue.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 10,
                      maxLength: 500,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Write your confession...\n\nShare what\'s on your mind anonymously.',
                        hintStyle: AppTextStyles.bodySmall,
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount/500',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: charCount > 500 ? Colors.red : AppColors.textGray,
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Info text
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your confession is completely anonymous',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Post button
              CustomButton(
                text: 'Post Confession',
                onPressed: _postConfession,
                isLoading: _isPosting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}