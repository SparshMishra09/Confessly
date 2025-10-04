import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/confession_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'reaction_bar.dart';
import 'avatar_widget.dart';

class ConfessionCard extends StatelessWidget {
  final Confession confession;
  final VoidCallback? onDelete;
  final Function(String emoji) onReaction;
  final bool showDelete;

  const ConfessionCard({
    Key? key,
    required this.confession,
    this.onDelete,
    required this.onReaction,
    this.showDelete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and timestamp row
          Row(
            children: [
              AvatarWidget(
                icon: confession.avatarIcon,
                color: Color(confession.avatarColor),
                size: 40,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeago.format(confession.timestamp),
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      'User: ${confession.userId.substring(0, 8)}...',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (showDelete && onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Confession text
          Text(
            confession.text,
            style: AppTextStyles.confessionText,
          ),
          
          SizedBox(height: 16),
          
          // Reaction bar
          ReactionBar(
            reactions: confession.reactions,
            onReactionTap: onReaction,
          ),
        ],
      ),
    );
  }
}