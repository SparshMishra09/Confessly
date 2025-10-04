import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ReactionBar extends StatelessWidget {
  final Map<String, int> reactions;
  final Function(String emoji) onReactionTap;

  const ReactionBar({
    Key? key,
    required this.reactions,
    required this.onReactionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reactionEmojis = {
      'heart': '❤️',
      'laugh': '😂',
      'sad': '😢',
      'wow': '😮',
      'pray': '🙏',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: reactionEmojis.entries.map((entry) {
        int count = reactions[entry.key] ?? 0;
        
        return InkWell(
          onTap: () => onReactionTap(entry.key),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: count > 0 ? AppColors.secondaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.secondaryBlue,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(entry.value, style: TextStyle(fontSize: 18)),
                if (count > 0) ...[
                  SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}