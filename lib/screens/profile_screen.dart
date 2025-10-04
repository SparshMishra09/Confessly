import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/confession_model.dart';
import '../widgets/confession_card.dart';

class ProfileScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.user == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Text('Please sign in', style: AppTextStyles.body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Confessions', style: AppTextStyles.heading),
      ),
      body: StreamBuilder<List<Confession>>(
        stream: _firestoreService.getUserConfessions(authProvider.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading confessions', style: AppTextStyles.body),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📝', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text(
                    'No confessions yet',
                    style: AppTextStyles.subheading,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start sharing your thoughts!',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }
          
          List<Confession> confessions = snapshot.data!;
          
          return Column(
            children: [
              // Stats card
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.3),
                      AppColors.secondaryBlue.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Confessions',
                      confessions.length.toString(),
                    ),
                    _buildStatItem(
                      'Total Reactions',
                      confessions
                          .fold(0, (sum, c) => sum + c.reactionCount)
                          .toString(),
                    ),
                  ],
                ),
              ),
              
              // Confession list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: confessions.length,
                  itemBuilder: (context, index) {
                    return ConfessionCard(
                      confession: confessions[index],
                      showDelete: true,
                      onDelete: () => _showDeleteDialog(
                        context,
                        confessions[index].id,
                      ),
                      onReaction: (_) {},
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            fontSize: 32,
            color: AppColors.primaryPurple,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String confessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Delete Confession', style: AppTextStyles.subheading),
        content: Text(
          'Are you sure you want to delete this confession?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.deleteConfession(confessionId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}